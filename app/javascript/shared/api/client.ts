
export class ApiError extends Error {}

export type ApiResult<T> = { data: T; errors?: undefined } | { data?: undefined; errors: string[] };

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(norm(path), {
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    credentials: "same-origin",
    ...init,
  });

  const body = await response.json().catch(() => ({}));

  if (!response.ok) {
    const messages = (body as { errors?: string[] }).errors ?? [`HTTP ${response.status}`];
    throw new ApiError(messages.join("; "));
  }

  return (body as { data: T }).data;
}

function norm(path: string) {
  if (path.startsWith("/api")) return path;
  return `/api/v1${path}`;
}
