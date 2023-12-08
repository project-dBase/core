
const blockName = args[0];
const jsonData = args[1];
const ownerName = args[2];
const requestType = args[3];
const baseURL = args[4];
const currentDateTime = new Date().toISOString();
const myData =
{
    "Datum_i_vrijeme": currentDateTime,
    "Ime": blockName,
    "field": jsonData,
    "Ime_osobe_koja_unosi_podatke": ownerName,
    "vsrta_unosa": requestType,
};
const apiResponse = await Functions.makeHttpRequest({
    url: baseURL,
    method: "POST",
    data: myData
});


if (apiResponse.error) {
    console.error(apiResponse.error)
    throw Error("Request failed")
}


console.log('succes');

return Functions.encodeString('succes');


