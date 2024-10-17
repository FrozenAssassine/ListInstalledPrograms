
function formatDate(dateString) {
    if(dateString.includes(".") || dateString.length == 1)
        return dateString;

    const year = dateString.slice(0, 4);//year
    const month = dateString.slice(4, 6);//day
    const day = dateString.slice(6, 8);//month


    const date = new Date(`${year}-${month}-${day}`);
    return date.toLocaleDateString('de-DE', { year: 'numeric', month: 'numeric', day: 'numeric' });
}

function Show(rawFileData){
    let data = "";

    let lines = rawFileData.replaceAll("\"", "").split("\n");
    if(lines.length == 0)
        return;

    document.getElementById("device_name").innerText = lines[0];

    for(let item of MakeData(lines.slice(2))){
        let date = formatDate(item.date);
            
        data += `<tr>
            <td class='item_app'>${item.name}</td>
            <td class='item_version'>${item.version}</td>
            <td class='item_date'>${date}</td>
        </tr>`;
    };
    document.getElementById("tableBody").innerHTML = data;
}

function MakeData(lines) {
    const result = [];
    lines.forEach(item => {
        const lineS = item.split(',');
        if (lineS.length >= 2) {
            result.push({ name: lineS[0], version: lineS[1], date: lineS[2] });
        }
    });
    return result;
}

fetch('../finalList.plist')
    .then(resp => resp.text())
    .then(text => { Show(text); })
    .catch(error => console.error('Error fetching data:', error));