import datetime
import logging
from typing import Optional

from azure.search.documents.indexes.models import (
    AzureOpenAIEmbeddingSkill,
    IndexProjectionMode,
    InputFieldMappingEntry,
    OutputFieldMappingEntry,
    SearchIndexer,
    SearchIndexerDataContainer,
    SearchIndexerDataSourceConnection,
    SearchIndexerDataSourceType,
    SearchIndexerIndexProjection,
    SearchIndexerIndexProjectionSelector,
    SearchIndexerIndexProjectionsParameters,
    SearchIndexerSkillset,
    SplitSkill,
    IndexingSchedule,
    IndexingParameters,
    IndexingParametersConfiguration,
    IndexerExecutionEnvironment,
    FieldMapping,
    FieldMappingFunction,
)

from .cosmosmanager import CosmosManager

from .embeddings import AzureOpenAIEmbeddingService
from .listfilestrategy import ListFileStrategy
from .searchmanager import SearchManager
from .strategy import DocumentAction, SearchInfo, Strategy

logger = logging.getLogger("scripts")


class IntegratedCosmosVectorizerStrategy(Strategy):
    """
    Strategy for ingesting and vectorizing documents into a search service from files stored storage account
    """

    def __init__(
        self,
        list_file_strategy: ListFileStrategy,
        cosmos_manager: CosmosManager,
        search_info: SearchInfo,
        embeddings: AzureOpenAIEmbeddingService,
        subscription_id: str,
        search_service_user_assigned_id: str,
        document_action: DocumentAction = DocumentAction.Add,
        search_analyzer_name: Optional[str] = None,
        use_acls: bool = False,
        category: Optional[str] = None,
    ):

        self.list_file_strategy = list_file_strategy
        self.cosmos_manager = cosmos_manager
        self.document_action = document_action
        self.embeddings = embeddings
        self.subscription_id = subscription_id
        self.search_user_assigned_identity = search_service_user_assigned_id
        self.search_analyzer_name = search_analyzer_name
        self.use_acls = use_acls
        self.category = category
        self.search_info = search_info

    async def create_embedding_skill(self, index_name: str):
        skillset_name = f"{index_name}-skillset"

        split_skill = SplitSkill(
            name=f"{index_name}-split-skill",
            description="Split skill to chunk documents",
            text_split_mode="sentences",
            context="/document",
            # maximum_page_length=2048,
            # page_overlap_length=20,
            inputs=[
                InputFieldMappingEntry(name="text", source="/document/summary"),
            ],
            outputs=[OutputFieldMappingEntry(name="textItems", target_name="sentences")],
        )

        embedding_skill = AzureOpenAIEmbeddingSkill(
            name=f"{index_name}-embedding-skill",
            description="Skill to generate embeddings via Azure OpenAI",
            context="/document/sentences/*",
            resource_url=f"https://{self.embeddings.open_ai_service}.openai.azure.com",
            deployment_name=self.embeddings.open_ai_deployment,
            model_name=self.embeddings.open_ai_model_name,
            dimensions=self.embeddings.open_ai_dimensions,
            inputs=[
                InputFieldMappingEntry(name="text", source="/document/sentences/*"),
            ],
            outputs=[OutputFieldMappingEntry(name="embedding", target_name="vector")],
        )

        index_projection = SearchIndexerIndexProjection(
            selectors=[
                SearchIndexerIndexProjectionSelector(
                    target_index_name=index_name,
                    parent_key_field_name="parent_id",
                    source_context="/document/sentences/*",
                    mappings=[
                        InputFieldMappingEntry(name="summary", source="/document/sentences/*"),
                        InputFieldMappingEntry(name="embedding", source="/document/sentences/*/vector"),
                        InputFieldMappingEntry(name="start_timestamp", source="/document/start_timestamp"),
                        InputFieldMappingEntry(name="end_timestamp", source="/document/end_timestamp"),
                        InputFieldMappingEntry(name="video_id", source="/document/video_id"),
                        InputFieldMappingEntry(name="entra_oid", source="/document/entra_oid"),
                        InputFieldMappingEntry(name="scene_theme", source="/document/scene_theme"),
                        InputFieldMappingEntry(name="sentiment", source="/document/sentiment"),
                        InputFieldMappingEntry(name="characters", source="/document/characters"),
                        InputFieldMappingEntry(name="key_objects", source="/document/key_objects"),
                        InputFieldMappingEntry(name="actions", source="/document/actions"),
                    ],
                ),
            ],
            parameters=SearchIndexerIndexProjectionsParameters(
                projection_mode=IndexProjectionMode.SKIP_INDEXING_PARENT_DOCUMENTS
            ),
        )

        skillset = SearchIndexerSkillset(
            name=skillset_name,
            description="Skillset to chunk documents and generate embeddings",
            skills=[split_skill, embedding_skill],
            index_projection=index_projection,
        )

        return skillset

    async def setup(self):
        logger.info("Setting up search index using integrated vectorization...")
        search_manager = SearchManager(
            search_info=self.search_info,
            search_analyzer_name=self.search_analyzer_name,
            use_acls=self.use_acls,
            use_int_vectorization=True,
            embeddings=self.embeddings,
            search_images=False,
        )

        await search_manager.create_video_analysis_index()

        ds_client = self.search_info.create_search_indexer_client()

        ds_container = SearchIndexerDataContainer(name=self.cosmos_manager.container)
        ds_container.query = "SELECT CONCAT(c._rid, '-', action_summary.start_timestamp) as _rid, c.entra_oid, c.video_id, action_summary.start_timestamp, action_summary.end_timestamp, action_summary.summary, action_summary.actions, action_summary.key_objects, action_summary.characters, action_summary.scene_theme, action_summary.sentiment, c._ts FROM c JOIN action_summary IN c.action_summary WHERE c._ts >= @HighWaterMark ORDER BY c._ts"

        data_source_connection = SearchIndexerDataSourceConnection(
            name=f"{self.search_info.index_name}-cosmos",
            type=SearchIndexerDataSourceType.COSMOS_DB,
            connection_string=self.cosmos_manager.get_managedidentity_connectionstring(),
            container=ds_container,
        )

        await ds_client.create_or_update_data_source_connection(data_source_connection)

        embedding_skillset = await self.create_embedding_skill(self.search_info.index_name)
        await ds_client.create_or_update_skillset(embedding_skillset)
        await ds_client.close()

    async def run(self):

        indexer = SearchIndexer(
            name=self.search_info.indexer_name,
            description="Indexer to index documents and generate embeddings",
            skillset_name=f"{self.search_info.index_name}-skillset",
            target_index_name=self.search_info.index_name,
            data_source_name=f"{self.search_info.index_name}-cosmos",
            schedule=IndexingSchedule(interval=datetime.timedelta(minutes=5)),
            parameters=IndexingParameters(
                configuration=IndexingParametersConfiguration(
                    execution_environment=IndexerExecutionEnvironment.PRIVATE,
                    parsing_mode=None,
                    excluded_file_name_extensions=None,
                    indexed_file_name_extensions=None,
                    fail_on_unsupported_content_type=None,
                    fail_on_unprocessable_document=None,
                    index_storage_metadata_only_for_oversized_documents=None,
                    first_line_contains_headers=None,
                    markdown_parsing_submode=None,
                    markdown_header_depth=None,
                    data_to_extract=None,
                    image_action=None,
                    allow_skillset_to_read_file_data=None,
                    pdf_text_rotation_algorithm=None,
                )
            ),
            # Map the metadata_storage_name field to the title field in the index to display the PDF title in the search results
            field_mappings=[
                FieldMapping(
                    source_field_name="rid",
                    target_field_name="id",
                    mapping_function=FieldMappingFunction(
                        name="base64Encode", parameters={"useHttpServerUtilityUrlTokenEncode": False}
                    ),
                )
            ],
        )

        indexer_client = self.search_info.create_search_indexer_client()
        indexer_result = await indexer_client.create_or_update_indexer(indexer)

        # Run the indexer
        await indexer_client.run_indexer(self.search_info.indexer_name)
        await indexer_client.close()

        logger.info(
            f"Successfully created index, indexer: {indexer_result.name}, and skillset. Please navigate to search service in Azure Portal to view the status of the indexer."
        )
