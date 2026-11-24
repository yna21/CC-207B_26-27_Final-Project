// WEBSUPARK: reads the vehicle pass number from a photo.
// Defines window.recognizePassImage(dataUrl) -> Promise<string>, which the
// Flutter code calls (see services/pass_recognition_service.dart).
// Tesseract.js must be loaded BEFORE this file.
//
// Pass formats: S + 3 digits (student/parent), E + 3 digits (faculty/staff),
// 3 digits (Yellow pass).
(function () {
  let workerPromise = null;

  function getWorker() {
    if (!workerPromise) {
      workerPromise = (async () => {
        const worker = await Tesseract.createWorker('eng');
        await worker.setParameters({
          // letters S and E, plus digits
          tessedit_char_whitelist: 'SE0123456789',
          tessedit_pageseg_mode:
            (Tesseract.PSM && Tesseract.PSM.SPARSE_TEXT) || '11',
        });
        return worker;
      })();
      workerPromise.catch(() => { workerPromise = null; });
    }
    return workerPromise;
  }

  function loadImage(src) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error('Could not load the photo.'));
      img.src = src;
    });
  }

  // Grayscale copy for the OCR. `invert` covers light-on-dark numbers,
  // `mirror` covers photos taken by a front (selfie) camera.
  function prepare(img, invert, mirror) {
    const longSide = Math.max(img.naturalWidth, img.naturalHeight);
    const scale = Math.min(2, Math.max(0.5, 1600 / longSide));
    const canvas = document.createElement('canvas');
    canvas.width = Math.round(img.naturalWidth * scale);
    canvas.height = Math.round(img.naturalHeight * scale);
    const ctx = canvas.getContext('2d');
    ctx.filter = invert
      ? 'grayscale(1) invert(1) contrast(1.4)'
      : 'grayscale(1) contrast(1.4)';
    if (mirror) {
      ctx.translate(canvas.width, 0);
      ctx.scale(-1, 1);
    }
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    return canvas;
  }

  // A letter S/E followed by 3 digits ("S 921", "E456").
  const hasLetteredPass = (text) => /(^|[^A-Z0-9])[SE]\s?[0-9]{3}([^0-9]|$)/.test(text);

  window.recognizePassImage = async function (imageDataUrl) {
    const worker = await getWorker();
    const img = await loadImage(imageDataUrl);

    // [invert colors, mirror]
    const attempts = [[false, false], [false, true], [true, false]];
    let all = '';
    for (const [invert, mirror] of attempts) {
      const text =
        (await worker.recognize(prepare(img, invert, mirror))).data.text || '';
      all += '\n' + text;
      if (hasLetteredPass(text)) break;
    }
    console.log('OCR read:', JSON.stringify(all));
    return all;
  };
})();