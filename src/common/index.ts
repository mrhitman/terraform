export function readFromEnv(name: string, defaultValue?: string) {
  const value = process.env[name] ?? defaultValue;

  if (value === null || value === undefined) {
    throw new Error(`No required env ${name}`);
  }

  return value;
}
