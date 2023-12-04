const baseURL = args[0]; const fieldToSearch = args[1]; const apiResponse = await Functions.makeHttpRequest({ url: baseURL }); if (apiResponse.error) { console.error(apiResponse.error); throw Error('Request failed'); } const { data } = apiResponse; console.log('API response data:', JSON.stringify(data, null, 2)); const jsonData = data.jsonData; const fieldValue = jsonData && jsonData[fieldToSearch]; if (fieldValue !== undefined) { return Functions.encodeString(fieldValue); } else { throw Error(`Field '${fieldToSearch}' not found in jsonData`); }