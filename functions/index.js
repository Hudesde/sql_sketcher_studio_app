const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({ origin: true });

// Levanta la Cloud Function que actuará como proxy seguro a la API de OpenAI.
exports.generateSql = functions.https.onCall(async (data, context) => {
  // Opcional: Verificar que el usuario esté autenticado.
  // if (!context.auth) {
  //   throw new functions.https.HttpsError(
  //       "unauthenticated",
  //       "Debes estar autenticado para realizar esta acción.",
  //   );
  // }

  const openAIKey = functions.config().openai.key;
  if (!openAIKey) {
    throw new functions.https.HttpsError(
        "internal",
        "La API Key de OpenAI no está configurada en el servidor.",
    );
  }

  const prompt = data.prompt;
  if (!prompt) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "El prompt no puede estar vacío.",
    );
  }

  try {
    const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content": "Eres un experto en SQL. Genera código SQL basado en la siguiente descripción de tablas. El código debe ser limpio, legible y compatible con MySQL.",
            },
            {
              "role": "user",
              "content": prompt,
            },
          ],
        },
        {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openAIKey}`,
          },
        },
    );

    if (response.data && response.data.choices && response.data.choices.length > 0) {
      return {sql: response.data.choices[0].message.content.trim()};
    } else {
      throw new functions.https.HttpsError(
          "internal",
          "La respuesta de OpenAI no tuvo el formato esperado.",
      );
    }
  } catch (error) {
    console.error("Error llamando a la API de OpenAI:", error.response ? error.response.data : error.message);
    throw new functions.https.HttpsError(
        "unknown",
        "Ocurrió un error al generar el código SQL.",
        error.toString(),
    );
  }
});
