using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using FluentAssertions;
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

    public class TaskPropertiesJson
    {
        public string Description { get; set; }
        public int ColumnId { get; set; }
    }

    public class TaskManipulation
    {
        private readonly HttpClient _client;

        public TaskManipulation()
        {
            var server = new TestServer(TestServer.CreateBuilder()
                .UseStartup<Startup>());
            _client = server.CreateClient();
        }

        [Fact]
        public async Task AddTask_ThenUpdate_AndThenGetTask()
        {
            // Act - add task
            const string description = "DESCRIPTION";
            var addResponseString = await Act_AddTask(description);

            // Assert - response id
            var addResult = Assert_AddResponseIdIsValid(addResponseString);

            // Act - update
            const string newDescription = "NEW DESCRIPTION";
            await Act_UpdateTask(addResult.Id, newDescription);

            // Assert - get description
            var getResponse = await _client.GetAsync($"api/task/{addResult.Id}");
            var getResponseString = await getResponse.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
            var getResult = JsonConvert.DeserializeObject<GetTaskResponseJson>(getResponseString);
            getResult.Description.Should().Be(newDescription, "description should be retrieved after modification");

        }

        [Fact]
        public async Task AddTask_ThenRemove_AndThenGetTask()
        {
            // Act
            var addResponseString = await Act_AddTask("DESCRIPTION");

            // Assert
            var addResult = Assert_AddResponseIdIsValid(addResponseString);

            // Act
            await Act_RemoveTask(addResult.Id);

            var getResponse = await _client.GetAsync($"api/task/{addResult.Id}");
            getResponse.StatusCode.Should()
                .Be(HttpStatusCode.NotFound, "get response with incorrect id should return not found status code");
        }

        private async Task<string> Act_AddTask(string description)
        {
            var postStringContent = new StringContent($"\"{description}\"");
            postStringContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var postResponse = await _client.PostAsync("/api/task/", postStringContent);

            var postResponseString = await postResponse.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
            return postResponseString;
        }

        private async Task<string> Act_UpdateTask(int id, string description)
        {
            var properties = new TaskPropertiesJson()
            {
                Description = description,
                ColumnId = 1
            };
            var content = new StringContent(JsonConvert.SerializeObject(properties));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await _client.PutAsync($"/api/task/{id}", content);

            var responseString = await response.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
            return responseString;
        }

        private async Task Act_RemoveTask(int id)
        {
            var response = await _client.DeleteAsync($"api/task/{id}");
            response.EnsureSuccessStatusCode();
        }

        private static AddTaskResponseJson Assert_AddResponseIdIsValid(string postResponseString)
        {
            var addResult = JsonConvert.DeserializeObject<AddTaskResponseJson>(postResponseString);
            addResult.Id.Should().BeGreaterThan(0, "correct ids are greater than zero");
            return addResult;
        }
    }
}
