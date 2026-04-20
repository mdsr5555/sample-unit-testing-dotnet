using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Hello from Azure");
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.MapGet("/storage-test", async (IConfiguration config) =>
{
    try
    {
        var connectionString = config["StorageConnectionString"];

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return Results.Problem("StorageConnectionString is missing.");
        }

        var serviceClient = new BlobServiceClient(connectionString);
        var containerClient = serviceClient.GetBlobContainerClient("connectivity-test");

        await containerClient.CreateIfNotExistsAsync();

        return Results.Ok(new
        {
            message = "Storage connection succeeded",
            container = containerClient.Name
        });
    }
    catch (Exception ex)
    {
        return Results.Problem($"Storage connection failed: {ex.Message}");
    }
});

app.Run();