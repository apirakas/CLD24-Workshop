## Step 0 - Setup the environment
### Install Azure CLi
This is the CLI used to control Azure.
Personally, I used Chocolatey to install it (since I am on Windows):
```PowerShell
choco install azure-cli -y
```
And then logged in my Azure account:
```PowerShell
az login
```