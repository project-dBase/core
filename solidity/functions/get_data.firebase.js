
const apiResponse = await Functions.makeHttpRequest({
    url: 'https://fir-task-menanger-default-rtdb.europe-west1.firebasedatabase.app/dBase/.json'
});
if (apiResponse.error) {
    console.log(apiResponse.error);
    throw Error('Request failed');
}

const { data } = apiResponse;

const result = {
    text: data.text,
    isActive: data.isActive,
    jsonData: JSON.stringify(data.jsonData)  // Keep jsonData as a JSON string
};


console.log('API response data:', JSON.stringify(result, null, 2));

return Functions.encodeString(JSON.stringify(result));