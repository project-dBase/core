const baseURL = args[0];
const fieldToSearch = args[1];
const blockName = args[2];

const apiResponse = await Functions.makeHttpRequest({
    url: baseURL + "?filter=(Ime='" + blockName + "')",
});


if (apiResponse.error) {
    console.error(apiResponse.error);
    throw Error('Request failed');
}

const { data } = apiResponse;

console.log('API response data:', JSON.stringify(data, null, 2));

// Check if jsonData exists and if the specified field exists inside it
const jsonData = data.jsonData;
const fieldValue = jsonData && jsonData[fieldToSearch];

if (fieldValue !== undefined) {
    // Return the value of the specified field
    return Functions.encodeString(fieldValue);
} else {
    // Handle the case when the specified field is not found
    throw Error(`Field '${fieldToSearch}' not found in jsonData`);
}
