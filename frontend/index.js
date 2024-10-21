let appItems;

function formatDate(dateString) {
    if (!dateString || dateString.includes(".") || dateString.length == 1) return !dateString ? "-" : dateString;

    const year = dateString.slice(0, 4); //year
    const month = dateString.slice(4, 6); //day
    const day = dateString.slice(6, 8); //month

    const date = new Date(`${year}-${month}-${day}`);
    return date.toLocaleDateString("de-DE", { year: "numeric", month: "numeric", day: "numeric" });
}

let compareDirection = [0,0,0,0];

function toggleCompareDirection(index){
  compareDirection[index] = compareDirection[index] == 0 ? 1 : 0;
}
function handleCompare(a, b, index){
  if (a < b) {
    return compareDirection[index] == 0 ? - 1 : 1;
  }
  if (a > b) {
    return compareDirection[index] == 0 ? 1 : -1;
  }
  return 0;
}

function compareApp(a, b) {
  return handleCompare(a.name, b.name, 0);
}
function compareMaintainer(a, b) {
  return handleCompare(a.maintainer, b.maintainer, 1);

}
function compareDate(a, b) {
  return handleCompare(a.date, b.date, 2);
}
function compareVersion(a, b) {
  return handleCompare(a.version, b.version, 3);
}

function compareAppClick() {
    toggleCompareDirection(0);
    appItems.sort(compareApp);
    Update();
}
function compareMaintainerClick() {
  toggleCompareDirection(1);

    appItems.sort(compareMaintainer);
    Update();
}
function compareDateClick() {
  toggleCompareDirection(2);

    appItems.sort(compareDate);
    Update();
}
function compareVersionClick() {
    toggleCompareDirection(3);
    appItems.sort(compareVersion);
    Update();
}

function Update() {
    document.getElementById("tableBody").innerHTML = "";

    let data = "";
    for (let item of appItems) {
        if (item.name == "") continue;

        let date = formatDate(item.date);

        data += `<tr>
            <td class='item_app'>${item.name}</td>
            <td class='item_version'>${item.version}</td>
            <td class='item_date'>${date}</td>
            <td class='item_maintainer'>${item.maintainer}</td>
        </tr>`;
    }
    document.getElementById("tableBody").innerHTML = data;
}

function Load(rawFileData) {
    let lines = rawFileData.replaceAll('"', "").split("\n");
    if (lines.length == 0) return;

    appItems = MakeData(lines.slice(2));

    document.getElementById("device_name").innerText = lines[0];
    Update();
}

function MakeData(lines) {
    const result = [];
    lines.forEach((item) => {
        const lineS = item.split(",");
        if (lineS.length >= 2) {
            result.push({ name: lineS[0], version: lineS[1], date: lineS[2], maintainer: lineS[3] });
        }
    });
    return result;
}

fetch("../finalList.plist")
    .then((resp) => resp.text())
    .then((text) => {
        Load(text);
    })
    .catch((error) => console.error("Error fetching data:", error));
