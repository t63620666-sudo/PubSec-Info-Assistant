from typing import Optional, Union
from azure.core.credentials_async import AsyncTokenCredential


class CosmosManager:
    """
    Class to manage Cosmos DB account and container
    """

    def __init__(
        self,
        endpoint: str,
        account: str,
        database: str,
        container: str,
        credential: Union[AsyncTokenCredential, str],
        resourceGroup: str,
        subscriptionId: str,
    ):
        self.endpoint = endpoint
        self.credential = credential
        self.account = account
        self.database = database
        self.container = container
        self.resourceGroup = resourceGroup
        self.subscriptionId = subscriptionId

    def get_managedidentity_connectionstring(self):
        return f"ResourceId=/subscriptions/{self.subscriptionId}/resourceGroups/{self.resourceGroup}/providers/Microsoft.DocumentDB/databaseAccounts/{self.account};Database={self.database};IdentityAuthType=AccessToken"