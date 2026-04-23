export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return jsonResponse(
        { errors: [{ message: "Only POST is supported" }] },
        405
      );
    }

    const body = await request.json();
    const query = body.query ?? "";
    const variables = body.variables ?? {};

    if (query.includes("GetReadings")) {
      const { results } = await env.DB
        .prepare("SELECT id, value, emoji, date FROM readings ORDER BY date DESC")
        .all();

      return jsonResponse({
        data: {
          readings: results.map(reading => ({
            __typename: "Reading",
            id: reading.id,
            value: reading.value,
            emoji: reading.emoji,
            date: reading.date
          }))
        }
      });
    }

    if (query.includes("SubmitReading")) {
      const input = variables.input;

      if (!input) {
        return jsonResponse(
          { errors: [{ message: "Missing input" }] },
          400
        );
      }

      const id = crypto.randomUUID();

      await env.DB
        .prepare("INSERT INTO readings (id, value, emoji, date) VALUES (?, ?, ?, ?)")
        .bind(id, input.value, input.emoji, input.date)
        .run();

      const newReading = {
        __typename: "Reading",
        id,
        value: input.value,
        emoji: input.emoji,
        date: input.date
      };

      return jsonResponse({
        data: {
          submitReading: newReading
        }
      });
    }

    if (query.includes("DeleteReading")) {
      const id = variables.id;

      if (!id) {
        return jsonResponse(
          { errors: [{ message: "Missing id" }] },
          400
        );
      }

      const result = await env.DB
        .prepare("DELETE FROM readings WHERE id = ?")
        .bind(id)
        .run();

      return jsonResponse({
        data: {
          deleteReading: result.meta.changes > 0
        }
      });
    }

    if (query.includes("ClearAllReadings")) {
      await env.DB
        .prepare("DELETE FROM readings")
        .run();

      return jsonResponse({
        data: {
          clearAllReadings: true
        }
      });
    }

    return jsonResponse(
      { errors: [{ message: "Unknown operation" }] },
      400
    );
  }
};

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json"
    }
  });
}
