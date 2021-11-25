import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtAuthApp 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    property alias portalUrl: portalUrlTextInput.text
    property string token

    Page {
        anchors.fill: parent

        header: Frame {
            background: Rectangle {
            }

            TextInput {
                id: portalUrlTextInput

                width: parent.width

                property string defaultPortalUrl: ""
                text: defaultPortalUrl

                onTextEdited: {
                    Settings.setValue("portalUrl", text);
                }

                Component.onCompleted: {
                    text = Settings.value("portalUrl", defaultPortalUrl);
                }

                Text {
                    id: placeholderText

                    anchors.fill: parent

                    text: qsTr("Specify Portal URL")
                    visible: !parent.text
                    color: "#c0c0c0"
                }
            }
        }

        Flickable {
            id: flickable

            anchors.fill: parent
            anchors.margins: 10

            contentWidth: results.width
            contentHeight: results.height
            clip: true

            TextEdit {
                id: results
                width: flickable.width
                readOnly: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                selectByMouse: true

                function clear() {
                    text = "";
                }

                function log(...params) {
                    console.log(...params);
                    text += params.join(" ") + "\n";
                }
            }
        }

        footer: Frame {
            background: Rectangle {
            }

            RowLayout {
                width: parent.width

                Button {
                    text: qsTr("Start")
                    onClicked: {
                        results.clear();
                        generateToken.submit();
                    }
                }
            }
        }
    }

    NetworkRequest {
        id: generateToken
        method: "POST"
        url: "%1/portal/sharing/rest/generateToken".arg(portalUrl)
        property var formData: ( {
                                    referer: portalUrl,
                                    f: "pjson"
        } )
        property var responseData

        onReadyStateChanged: {
            results.log("readyState: ", readyState);
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            results.log("status: ", status);
            // qml: status:  200

            results.log("response: ", responseText);
            // qml: response:  {
            //   "token": "SomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeTokenSomeToken.",
            //   "expires": 1637646553020,
            //   "ssl": true
            // }

            results.log("headers: ", JSON.stringify(responseHeaders, undefined, 2));
            // qml: headers:  {
            //   "Cache-Control": "no-cache",
            //   "Content-Encoding": "gzip",
            //   "Content-Type": "text/plain;charset=utf-8",
            //   "Date": "Tue, 23 Nov 2021 05:19:12 GMT",
            //   "Expires": "-1",
            //   "Persistent-Auth": "true",
            //   "Pragma": "no-cache",
            //   "Server": "Microsoft-IIS/10.0, ",
            //   "Set-Cookie": "esri_auth=%7B%22email%22%3A%22someone%40SOMEDOMAIN%22%2C%22privacy%22%3A%22public%22%2C%22token%22%3A%22qcWhLM9wiabKKnNB62g8iSEWQFLJPYKWFGGr85a_xRE5eC-6MC8PGDtwoRjCQ53x3ttaeG4s_6vZSrZb4uBNb7ujiZAit6kvhqZg7AJjQ6JWwICsmw8eq581JeIzCf8hK4DjTRA59BnG5aamEKQiikqtg2buGYkNk-tisT-REYk.%22%2C%22accountId%22%3A%220123456789ABCDEF%22%2C%22role%22%3A%22account_admin%22%2C%22ssl%22%3Atrue%2C%22culture%22%3A%22en-US%22%2C%22region%22%3A%22%22%2C%22auth_tier%22%3A%22web%22%2C%22portalApp%22%3A%22true%22%7D; Max-Age=7200; Expires=Tue, 23-Nov-2021 07:19:13 GMT; Domain=somewhere; Path=/; Secure\nesri_auth=%7B%22email%22%3A%22someone%40SOMEDOMAIN%22%2C%22privacy%22%3A%22public%22%2C%22token%22%3A%22e6qr_N9Wd7f5fsYNL2OaSWsT6gr4ySpkEi3cKficigUBiup24O69lN9XZWP29InBO-vyLfqbHlb3G5uxrojHwisTh1ZjPlebtQ53CN2Ed254st-ngBVdK9cGvzuGgeHWPSFkwX8iGrlwBnx_3LX_Im83H-YrY7OHycSOpCpS2mc.%22%2C%22accountId%22%3A%220123456789ABCDEF%22%2C%22role%22%3A%22account_admin%22%2C%22ssl%22%3Atrue%2C%22culture%22%3A%22en-US%22%2C%22region%22%3A%22%22%2C%22auth_tier%22%3A%22web%22%2C%22portalApp%22%3A%22true%22%7D; Max-Age=7200; Expires=Tue, 23-Nov-2021 07:19:13 GMT; Domain=somewhere; Path=/; Secure",
            //   "Vary": "Origin",
            //   "X-AspNet-Version": "4.0.30319",
            //   "X-Content-Type-Options": "nosniff",
            //   "X-Powered-By": "ASP.NET",
            //   "X-XSS-Protection": "1; mode=block"
            // }

            responseData = JSON.parse(responseText);
            token = responseData.token;

            relatedItems.submit();
        }

        function submit() {
            results.log("method: ", method, "url: ", url, "formData: ", JSON.stringify(formData));
            send(formData);
        }
    }

    NetworkRequest {
        id: relatedItems
        method: "POST"
        url: "%1/portal/sharing/rest/content/items/a0772f84dc744cbebb148d36eb98eb0e/relatedItems".arg(portalUrl)
        property var formData: ( {
                                    "relationshipType": "Survey2Service",
                                    "direction": "forward",
                                    "token": token,
                                    "f": "pjson"
        } )
        property var responseData

        onReadyStateChanged: {
            results.log("readyState: ", readyState);
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            results.log("status: ", status);
            // qml: status:  200

            results.log("response: ", responseText);
            // qml: response:  {
            //   "total": 1,
            //   "relatedItems": [
            //     {
            //       "id": "4a3b078738c84f26ba475e234debab8b",
            //       "owner": "someone@SOMEDOMAIN",
            //       "created": 1629846632009,
            //       "modified": 1629846637284,
            //       "guid": null,
            //       "name": "service_30ef9090bb6b4d139e0d07a9f1b8bcdb",
            //       "title": "Appearances 13732",
            //       "type": "Feature Service",
            //       "typeKeywords": [
            //         "ArcGIS Server",
            //         "Data",
            //         "Feature Access",
            //         "Feature Service",
            //         "providerSDS",
            //         "Service",
            //         "Hosted Service"
            //       ],
            //       "description": null,
            //       "tags": [
            //
            //       ],
            //       "snippet": null,
            //       "thumbnail": "thumbnail/Appearances_13732.png",
            //       "documentation": null,
            //       "extent": [
            //
            //       ],
            //       "categories": [
            //
            //       ],
            //       "spatialReference": null,
            //       "accessInformation": null,
            //       "licenseInfo": null,
            //       "culture": "",
            //       "properties": null,
            //       "url": "https://somewhere/server/rest/services/Hosted/service_30ef9090bb6b4d139e0d07a9f1b8bcdb/FeatureServer",
            //       "proxyFilter": null,
            //       "access": "private",
            //       "size": 0,
            //       "appCategories": [
            //
            //       ],
            //       "industries": [
            //
            //       ],
            //       "languages": [
            //
            //       ],
            //       "largeThumbnail": null,
            //       "banner": null,
            //       "screenshots": [
            //
            //       ],
            //       "listed": false,
            //       "numComments": 0,
            //       "numRatings": 0,
            //       "avgRating": 0,
            //       "numViews": 0,
            //       "scoreCompleteness": 33,
            //       "groupDesignations": null
            //     }
            //   ]
            // }

            results.log("headers: ", JSON.stringify(responseHeaders, undefined, 2));
            // qml: headers:  {
            //   "Cache-Control": "no-cache",
            //   "Content-Encoding": "gzip",
            //   "Content-Type": "text/plain;charset=utf-8",
            //   "Date": "Tue, 23 Nov 2021 05:19:13 GMT",
            //   "Expires": "-1",
            //   "Persistent-Auth": "true",
            //   "Pragma": "no-cache",
            //   "Server": "Microsoft-IIS/10.0, ",
            //   "Vary": "Origin",
            //   "X-AspNet-Version": "4.0.30319",
            //   "X-Content-Type-Options": "nosniff",
            //   "X-Powered-By": "ASP.NET",
            //   "X-XSS-Protection": "1; mode=block"
            // }

            responseData = JSON.parse(responseText);

            featureServer.submit();
        }

        function submit() {
            results.log("method: ", method, "url: ", url, "formData: ", JSON.stringify(formData));
            send(formData);
        }
    }

    NetworkRequest {
        id: featureServer
        method: "POST"
        url: "%1/server/rest/services/Hosted/service_30ef9090bb6b4d139e0d07a9f1b8bcdb/FeatureServer".arg(portalUrl)
        property var formData: ( {
                                    "token": token,
                                    "f": "pjson"
        } )
        property var responseData

        onReadyStateChanged: {
            results.log("readyState: ", readyState);
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            results.log("status: ", status);
            // qml: status:  200

            results.log("response: ", responseText);
            // qml: response:  {
            //  "hasVersionedData": false,
            //  "supportsDisconnectedEditing": false,
            //  "supportedQueryFormats": "JSON",
            //  "currentVersion": 10.81,
            //  "serviceDescription": "Appearances 13732",
            //  "maxRecordCount": 1000,
            //  "capabilities": "Create,Editing,Uploads,Query,Update,Delete,Sync,Extract",
            //  "description": "",
            //  "copyrightText": "",
            //  "spatialReference": {"wkid": 4326},
            //  "fullExtent": {
            //   "spatialReference": {"wkid": 4326},
            //   "type": "extent",
            //   "xmax": 180,
            //   "xmin": -180,
            //   "ymax": 90,
            //   "ymin": -90
            //  },
            //  "initialExtent": {
            //   "spatialReference": {"wkid": 4326},
            //   "type": "extent",
            //   "xmax": 180,
            //   "xmin": -180,
            //   "ymax": 90,
            //   "ymin": -90
            //  },
            //  "units": "esriMeters",
            //  "allowGeometryUpdates": true,
            //  "enableZDefaults": true,
            //  "zDefault": 0,
            //  "syncEnabled": true,
            //  "syncCapabilities": {
            //   "supportsRegisteringExistingData": true,
            //   "supportsSyncDirectionControl": true,
            //   "supportsPerLayerSync": true,
            //   "supportsPerReplicaSync": false,
            //   "supportsRollbackOnFailure": false,
            //   "supportsAsync": true,
            //   "supportsSyncModelNone": true,
            //   "supportsAttachmentsSyncDirection": true
            //  },
            //  "supportsApplyEditsWithGlobalIds": true,
            //  "maxViewsCount": 20,
            //  "sourceSchemaChangesAllowed": true,
            //  "editorTrackingInfo": {
            //   "allowOthersToDelete": true,
            //   "enableOwnershipAccessControl": false,
            //   "enableEditorTracking": true,
            //   "allowOthersToUpdate": true,
            //   "allowOthersToQuery": true
            //  },
            //  "supportsReturnDeleteResults": true,
            //  "isLocationTrackingService": false,
            //  "hasSyncEnabledViews": false,
            //  "hasViews": false,
            //  "supportsAppend": true,
            //  "supportedAppendFormats": "shapefile,featureCollection",
            //  "layers": [
            //   {
            //    "id": 0,
            //    "name": "Appearances_13732"
            //   }
            //  ],
            //  "tables": [
            //   {
            //    "id": 1,
            //    "name": "minimal_repeat"
            //   },
            //   {
            //    "id": 2,
            //    "name": "minimal_compact"
            //   }
            //  ],
            //  "serviceItemId": "4a3b078738c84f26ba475e234debab8b"
            // }

            results.log("headers: ", JSON.stringify(responseHeaders, undefined, 2));
            // qml: headers:  {
            //   "Cache-Control": "public, must-revalidate, max-age=0",
            //   "Content-Encoding": "gzip",
            //   "Content-Type": "text/plain;charset=UTF-8",
            //   "Date": "Tue, 23 Nov 2021 05:19:13 GMT",
            //   "Server": "Microsoft-IIS/10.0, ",
            //   "Set-Cookie": "AGS_ROLES=\"dDyVmj8dIH7QXQrq4I+3X/bau+dmkw4CGY8pn4WCnxpDhuZx4o/BWS4S60rQfOCO/n/NETiCP4mSm58GfjteZQ==\"; Version=1; Max-Age=60; Expires=Tue, 23-Nov-2021 05:20:13 GMT; Path=/server/rest; Secure; HttpOnly",
            //   "Vary": "Origin",
            //   "X-AspNet-Version": "4.0.30319",
            //   "X-Content-Type-Options": "nosniff",
            //   "X-Powered-By": "ASP.NET",
            //   "X-XSS-Protection": "1; mode=block"
            // }

            responseData = JSON.parse(responseText);

            //Networking.clearAccessCache(); // WORKAROUND

            content.submit();
        }

        function submit() {
            results.log("method: ", method, "url: ", url, "formData: ", JSON.stringify(formData));
            send(formData);
        }
    }

    NetworkRequest {
        id: content
        method: "POST"
        url: "%1/portal/sharing/rest/content/items/a0772f84dc744cbebb148d36eb98eb0e".arg(portalUrl)
        property var formData: ( {
                                    "token": token,
                                    "f": "pjson"
        } )
        property var responseData

        onReadyStateChanged: {
            results.log("readyState: ", readyState);
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            results.log("status: ", status);
            // qml: status:  401

            results.log("response: ", responseText);
            // qml: response:  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
            // <html xmlns="http://www.w3.org/1999/xhtml">
            // <head>
            // <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
            // <title>401 - Unauthorized: Access is denied due to invalid credentials.</title>
            // <style type="text/css">
            // <!--
            // body{margin:0;font-size:.7em;font-family:Verdana, Arial, Helvetica, sans-serif;background:#EEEEEE;}
            // fieldset{padding:0 15px 10px 15px;}
            // h1{font-size:2.4em;margin:0;color:#FFF;}
            // h2{font-size:1.7em;margin:0;color:#CC0000;}
            // h3{font-size:1.2em;margin:10px 0 0 0;color:#000000;}
            // #header{width:96%;margin:0 0 0 0;padding:6px 2% 6px 2%;font-family:"trebuchet MS", Verdana, sans-serif;color:#FFF;
            // background-color:#555555;}
            // #content{margin:0 0 0 2%;position:relative;}
            // .content-container{background:#FFF;width:96%;margin-top:8px;padding:10px;position:relative;}
            // -->
            // </style>
            // </head>
            // <body>
            // <div id="header"><h1>Server Error</h1></div>
            // <div id="content">
            //  <div class="content-container"><fieldset>
            //   <h2>401 - Unauthorized: Access is denied due to invalid credentials.</h2>
            //   <h3>You do not have permission to view this directory or page using the credentials that you supplied.</h3>
            //  </fieldset></div>
            // </div>
            // </body>
            // </html>

            results.log("headers: ", JSON.stringify(responseHeaders, undefined, 2));
            // qml: headers:  {
            //   "Content-Length": "1293",
            //   "Content-Type": "text/html",
            //   "Date": "Tue, 23 Nov 2021 05:19:13 GMT",
            //   "Server": "Microsoft-IIS/10.0",
            //   "WWW-Authenticate": "Negotiate, NTLM",
            //   "X-Powered-By": "ASP.NET"
            // }

            if (status === 401) {
                contentRetry.submit();
                return;
            }

            responseData = JSON.parse(responseText);

            results.log("WORKS WITHOUT RETRY");
        }

        function submit() {
            results.log("method: ", method, "url: ", url, "formData: ", JSON.stringify(formData));
            send(formData);
        }
    }

    NetworkRequest {
        id: contentRetry
        method: "POST"
        url: "%1/portal/sharing/rest/content/items/a0772f84dc744cbebb148d36eb98eb0e".arg(portalUrl)
        property var formData: ( {
                                    "token": token,
                                    "f": "pjson"
        } )
        property var responseData

        onReadyStateChanged: {
            results.log("readyState: ", readyState);
            if (readyState !== NetworkRequest.ReadyStateComplete) {
                return;
            }

            results.log("response: ", responseText);
            //   qml: response:  {
            //   "id": "a0772f84dc744cbebb148d36eb98eb0e",
            //   "owner": "someone@SOMEDOMAIN",
            //   "created": 1629846823938,
            //   "isOrgItem": true,
            //   "modified": 1629846824010,
            //   "guid": null,
            //   "name": "Appearances_13732.zip",
            //   "title": "Appearances 13732",
            //   "type": "Form",
            //   "typeKeywords": [
            //     "Form",
            //     "Survey123",
            //     "Survey123 Connect",
            //     "xForm"
            //   ],
            //   "description": "<div>This sample demonstrates the different appearance types for questions in ArcGIS Survey123.<\/div><div><a href='https://community.esri.com/groups/survey123/blog/2016/11/11/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest' rel='nofollow ugc' target='_blank'>Resource level:<\/a> ????<\/div>",
            //   "tags": [],
            //   "snippet": null,
            //   "thumbnail": "thumbnail/Appearances_13732.png",
            //   "documentation": null,
            //   "extent": [],
            //   "categories": [],
            //   "spatialReference": null,
            //   "accessInformation": null,
            //   "licenseInfo": null,
            //   "culture": "en-au",
            //   "properties": null,
            //   "url": null,
            //   "proxyFilter": null,
            //   "access": "private",
            //   "size": 459361,
            //   "appCategories": [],
            //   "industries": [],
            //   "languages": [],
            //   "largeThumbnail": null,
            //   "banner": null,
            //   "screenshots": [],
            //   "listed": false,
            //   "ownerFolder": "6a815fb826544de096f554db78c6be9e",
            //   "protected": false,
            //   "commentsEnabled": false,
            //   "numComments": 0,
            //   "numRatings": 0,
            //   "avgRating": 0,
            //   "numViews": 1,
            //   "itemControl": "admin",
            //   "scoreCompleteness": 43,
            //   "groupDesignations": null
            // }

            results.log("headers: ", JSON.stringify(responseHeaders, undefined, 2));
            // qml: headers:  {
            //   "Cache-Control": "no-cache",
            //   "Content-Encoding": "gzip",
            //   "Content-Type": "text/plain;charset=utf-8",
            //   "Date": "Tue, 23 Nov 2021 05:19:14 GMT",
            //   "Expires": "-1",
            //   "Persistent-Auth": "true",
            //   "Pragma": "no-cache",
            //   "Server": "Microsoft-IIS/10.0, ",
            //   "Vary": "Origin",
            //   "X-AspNet-Version": "4.0.30319",
            //   "X-Content-Type-Options": "nosniff",
            //   "X-Powered-By": "ASP.NET",
            //   "X-XSS-Protection": "1; mode=block"
            // }

            responseData = JSON.parse(responseText);

            results.log("RETRY USED");
        }

        function submit() {
            results.log("method: ", method, "url: ", url, "formData: ", JSON.stringify(formData));
            send(formData);
        }
    }

}
