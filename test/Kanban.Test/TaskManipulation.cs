using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
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

    public class GetTaskResponseJson
    {
        public int Id { get; set; }
        public string Description { get; set; }
        public int ColumnId { get; set; }
    }

    public class TaskManipulation
    {
        private readonly TestServer _server;
        private readonly HttpClient _client;

        public TaskManipulation()
        {
            _server = new TestServer(TestServer.CreateBuilder()
                .UseStartup<Startup>());
            _client = _server.CreateClient();
        }

        [Fact]
        public async Task AddTask_ShouldGetResponseId_AndThenGetTask()
        {
            // Act
            const string description = "DESCRIPTION";
            var postResponseString = await Act_AddTask(description);

            // Assert
            var addResult = JsonConvert.DeserializeObject<AddTaskResponseJson>(postResponseString);
            Assert.True(addResult.Id > 0);

            // Act
            var getResponse = await _client.GetAsync($"api/task/{addResult.Id}");
            var getResponseString = await getResponse.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
            var getResult = JsonConvert.DeserializeObject<GetTaskResponseJson>(getResponseString);
            Assert.Equal(description, getResult.Description);

        }

       

        [Fact]
        public async Task AddTask_ThenRemove_AndThenGetTask()
        {
            // Act
            var addResponseString = await Act_AddTask("DESCRIPTION");
            
            // Assert
            var addResult = JsonConvert.DeserializeObject<AddTaskResponseJson>(addResponseString);
            Assert.True(addResult.Id > 0);

            // Act
            Act_RemoveTask(addResult.Id);

            var getResponse = await _client.GetAsync($"api/task/{addResult.Id}");
            Assert.False(getResponse.IsSuccessStatusCode); 
        }

        private async Task<string> Act_AddTask(string description)
        {
            var postStringContent = new StringContent($"\"{description}\"");
            postStringContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var postResponse = await _client.PostAsync("/api/task/", postStringContent);

            var postResponseString = await postResponse.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
            return postResponseString;
        }

        private async void Act_RemoveTask(int id)
        {
            var response = await _client.DeleteAsync($"api/task/{id}");
            response.EnsureSuccessStatusCode();
        }
    }
}
