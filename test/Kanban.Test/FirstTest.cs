using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNet.TestHost;
using Newtonsoft.Json;
using Xunit;

namespace Kanban.Test
{
    public class AddTaskResponseJson
    {
        public int Id { get; set; }
    }

    public class FirstTest
    {
        private readonly TestServer _server;
        private readonly HttpClient _client;

        public FirstTest()
        {
            _server = new TestServer(TestServer.CreateBuilder()
                .UseStartup<Startup>());
            _client = _server.CreateClient();
        }

        [Fact]
        public void DummyTest()
        {
            Assert.True(true);
        }

        [Fact]
        public async Task AddTask_ShouldGetResponseId()
        {
            // Act
            var stringContent = new StringContent("DESCRIPTION");
            var response = await _client.PostAsync("/api/task/", stringContent);
            response.EnsureSuccessStatusCode();

            var responseString = await response.Content.ReadAsStringAsync();

            // Assert
            var addResult = JsonConvert.DeserializeObject<AddTaskResponseJson>(responseString);
            Assert.True(addResult.Id > 0);
        }
    }
}
