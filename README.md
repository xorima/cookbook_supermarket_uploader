# Cookbook Supermarket Uploader

Uploads a cookbook source to the chef supermarket based on a github webhook event

## Configuration

### Environment Variables

This app uses the following environments variables:

| Name | Required | Description |
| ---| --- | ---|
| GITHUB_TOKEN| Yes| Token to access the github api, create the release and update the changelog on master |
| SECRET_TOKEN | Yes| If supplied it will do a HMAC check against the incomming request |
| NODE_NAME | Yes | The node name to connect to supermarket with |
| CLIENT_KEY | Yes | The path for the key to connect to supermarket with |

### Webhook

To configure the webhook you will want to do the following:

URL: <https://example.com/handler>
Events:
  Let me select:
    Deployments (Only)

If you set a HMAC secret ensure that `SECRET_TOKEN` is set to the same secret value

## Docker images

Docker images are supplied under Xorima on docker hub, <https://hub.docker.com/r/xorima/cookbook_supermarket_uploader/>
