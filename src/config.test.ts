import { describe, expect, it } from "vitest";

import nextConfig from "../next.config";

describe("next.config", () => {
  it("configures static export", () => {
    expect(nextConfig.output).toBe("export");
  });
});
