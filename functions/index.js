const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({ origin: true });

// Proxy para la API de OpenAI
exports.openaiProxy = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      // Realiza la solicitud a OpenAI
      const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        req.body,
        {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${functions.config().openai.key}`,
          },
        }
      );

      // Devuelve la respuesta de OpenAI
      res.status(200).send(response.data);
    } catch (error) {
      console.error("Error al comunicarse con OpenAI:", error);
      res.status(500).send({ error: "Error al comunicarse con OpenAI" });
    }
  });
});
