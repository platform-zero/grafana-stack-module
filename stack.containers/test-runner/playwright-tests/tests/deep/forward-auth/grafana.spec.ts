import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import {
  authenticatedSessionState,
  domain,
  screenshotRoot,
  seafileOnlyOfficeFixturePath,
  testForwardAuthService,
  waitForGrafanaShell,
  waitForHomeAssistantShell,
} from '../shared/forward-auth';
import { serviceUrl } from '../../../utils/stack-urls';
import { logPageTelemetry, setupNetworkLogging } from '../../../utils/telemetry';

test.use({ storageState: authenticatedSessionState });

  test('Grafana - Logs home + Loki datasource', async ({ page }) => {
    await testForwardAuthService(
      page,
      'Grafana',
      serviceUrl('grafana'),
      /Grafana|Dashboards|Explore|Connections|Data sources|Loki/i,
      {
        onAfterLoad: async (page) => {
          await waitForGrafanaShell(page);
        },
        screenshotDelayMs: 2000,
        screenshotFullPage: false,
        screenshotViewport: { width: 1280, height: 360 },
      }
    );

    // Validate default home dashboard shows Logs panel
    const logsPanelTitle = page.getByText('All Logs', { exact: false }).first();
    await expect(logsPanelTitle).toBeVisible();

    // Validate Loki datasource via Grafana API
    const response = await page.request.get(serviceUrl('grafana', '/api/datasources/name/Loki'));
    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data.type).toBe('loki');
    expect(String(data.url)).toContain('http://loki:3100');

    const now = Date.now();
    const queryResponse = await page.request.post(serviceUrl('grafana', '/api/ds/query'), {
      data: {
        from: String(now - 60 * 60 * 1000),
        to: String(now),
        queries: [{
          refId: 'A',
          expr: '{source="journald"}',
          queryType: 'range',
          maxLines: 100,
          datasource: { type: 'loki', uid: 'loki' },
        }],
      },
    });
    expect(queryResponse.status()).toBe(200);
    const queryData = await queryResponse.json();
    expect(queryData.results?.A?.frames?.length ?? 0).toBeGreaterThan(0);
    await expect(page.getByText('No data', { exact: true })).toHaveCount(0);
  });
