import OpenAI from "openai";
import { openAIApiKey } from "../config";

const openai = new OpenAI({
  apiKey: openAIApiKey,
});

export async function accessGPTVision(
  imageBase64: string,
  imageProcessingCommand: string,
): Promise<string | null> {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: imageProcessingCommand },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${imageBase64}`,
              },
            },
          ],
        },
      ],
    });
    return response.choices[0].message.content;
  } catch (err) {
    return null;
  }
}

export async function convertTextToMp3Base64Audio(
  text: string,
): Promise<Buffer | null> {
  try {
    const mp3 = await openai.audio.speech.create({
      model: "tts-1",
      voice: "nova",
      response_format: "mp3",
      input: text,
    });

    const buffer = Buffer.from(await mp3.arrayBuffer());
    return buffer;
  } catch (err) {
    return null;
  }
}

export type GPTChatMessage = {
  role: "user" | "assistant";
  content: string;
};

export async function accessGPTChat({
  text,
  previousChatMessages = [],
}: {
  text: string;
  previousChatMessages?: GPTChatMessage[];
}): Promise<string | null> {
  const response = await openai.chat.completions.create({
    model: "gpt-4o",
    messages: [
      ...previousChatMessages,
      {
        role: "user",
        content: [{ type: "text", text }],
      },
    ],
  });
  return response.choices[0].message.content;
}
