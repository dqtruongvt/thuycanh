const functions = require('firebase-functions');
const admin = require('firebase-admin');



admin.initializeApp(functions.config().firebase);

const firestore = admin.firestore();

//return date type dd/mm/yyyy to dd-mm-yyyy
function editDate(date) {
    var temp = String(date);
    var first = temp.indexOf('/');
    var second = temp.lastIndexOf('/');
    var dd = temp.substr(0, first);
    if (dd.length == 1) dd = '0' + dd;
    var mm = temp.substr(first + 1, second - first - 1);
    if (mm.length == 1) mm = '0' + mm;
    var yyyy = temp.substr(second + 1, 4);
    return dd + "-" + mm + "-" + yyyy;
}

exports.createDataCollection = functions.database.ref("key").onUpdate(async (snap, context) => {
    var key = snap.after.val();
    admin.database().ref("data").child(String(key - 1)).once("value", (snap2) => {
        var map = snap2.val();
        map.day = editDate(map.day);
        map.timestamp = new Date();
        firestore.collection("data").doc(String(key - 1)).set(map);
    });
});



function sum(value) {
    return admin.firestore.FieldValue.increment(value);
}

exports.caculateData = functions.database.ref("key").onUpdate(async (snap, context) => {
    var key = snap.after.val();
    admin.database().ref("data").child(String(key - 1)).once("value", (snap2) => {
        const map = snap2.val();
        const { day, ph, tds, temperature } = map;
        var documentCrop = admin.firestore().collection("crop").doc(editDate(day));
        var documentCaculate = admin.firestore().collection("caculate").doc("sum");

        documentCrop.get().then((document) => {
            if (document.exists) {
                documentCaculate.update({
                    ph: sum(ph),
                    tds: sum(tds),
                    temperature: sum(temperature),
                    times: sum(1),
                    day: day
                })
            }
            else {
                documentCaculate.set({
                    ph: ph,
                    tds: tds,
                    temperature: temperature,
                    times: 1,
                    day: day
                });
            }
        });
    });


});

exports.createCropCollection = functions.firestore.document("caculate/sum").onUpdate(async (snap, context) => {
    const data = snap.after.data();
    firestore.collection("crop").doc(editDate(data.day)).set({
        ph: data.ph / data.times,
        tds: data.tds / data.times,
        temperature: data.temperature / data.times,
        timestamp: new Date()
    });
});

exports.updateTest = functions.firestore.document("test/read").onUpdate(async (snap, context) => {
    admin.database().ref("test").once("value", (snap2) => {
            var map = snap2.val();
            firestore.collection("test").doc("data").set(map);
        });
});

exports.updatePumpFromFirestore = functions.firestore.document("test/pump").onUpdate(async (snap, context) => {
    var data = snap.after.data();
    admin.database().ref("pump").set(data.active);
});




