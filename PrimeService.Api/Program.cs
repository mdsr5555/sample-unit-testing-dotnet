var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Hello from Azure 🚀");

// Important for Azure Linux
app.Urls.Add("http://0.0.0.0:8080");

app.Run();