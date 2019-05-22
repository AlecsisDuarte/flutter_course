const functions = require('firebase-functions');
const cors = require('cors')({
  origin: true
});
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

const configPath = path.resolve(path.join(__dirname, ".config.json"));
const configJson = fs.readFileSync(configPath);
const config = JSON.parse(configJson);
// const config = require(__dirname  + '/assets/config.json');
// const config = require('config_json');

const gcconfig = {
  projectId: config.firebase.projectId,
  keyFilename: config.firebase.fileName
};
// const gcconfig = {
//   projectId: 'flutter-courser',
//   keyFilename: 'flutter-courser-products.json'
// };
const googleCloud = require('@google-cloud/storage')(gcconfig);

fbAdmin.initializeApp({
  credential: fbAdmin.credential.cert(require(`./${config.firebase.fileName}`))
});

exports.storeImage = functions.https.onRequest((req, res) => {
  return cors(req, res, () => {
    if (req.method !== 'POST') {
      return res.status(500).json({
        message: 'Not Allowed'
      });
    }
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Unauthorized'
      });
    }
    let idToken;
    idToken = req.headers.authorization.split('Bearer ')[1];
    const busboy = new Busboy({
      headers: req.headers
    });

    let uploadData;
    let oldImagePath;
    busboy.on('file', (fieldname, file, filename, encoding, mimeType) => {
      const filePath = path.join(os.tmpdir(), filename);
      uploadData = {
        filePath: filePath,
        type: mimeType,
        name: filename
      };

      file.pipe(fs.createWriteStream(filePath));
    });

    busboy.on('field', (fieldname, value) => {
      oldImagePath = decodeURIComponent(value);
    });

    busboy.on('finish', () => {

      const bucket = googleCloud.bucket(config.firebase.bucketName)
      // const bucket = googleCloud.bucket('flutter-courser.appspot.com')
      const id = uuid();
      let imagePath = `images/${id}-${uploadData.name}`;
      if (oldImagePath) {
        imagePath = oldImagePath;
      }
      return fbAdmin
        .auth()
        .verifyIdToken(idToken)
        .then((decodedToken) => {
          console.log('Token verified', decodedToken);
          return bucket.upload(uploadData.filePath, {
            uploadType: 'media',
            destination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadTokens: id
              }
            }
          });
        })
        .then(() => res.status(201).json({
          imageUrl: `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(imagePath)}?alt=media&token=${id}`,
          imagePath: imagePath,
        }))
        .catch(error => {
          console.error('fbAdmin_verifyToken', error, idToken);
          return res.status(401).json({
            error: 'Unauthorized'
          });
        });
    });
    return busboy.end(req.rawBody);
  });
});

exports.deleteImage = functions.database.ref('/products/{productId}').onDelete(snapshot => {
  const imageData = snapshot.val();
  const imagePath = imageData.imagePath;

  // const bucket = googleCloud.bucket('flutter-courser.appspot.com');
  const bucket = googleCloud.bucket(config.firebase.bucketName);
  return bucket.file(imagePath).delete();
});