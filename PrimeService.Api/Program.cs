var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Hello from Azure");
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();