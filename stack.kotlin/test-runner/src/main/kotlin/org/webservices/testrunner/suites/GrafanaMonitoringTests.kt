package org.webservices.testrunner.suites

import io.ktor.client.statement.bodyAsText
import io.ktor.http.HttpStatusCode
import org.webservices.testrunner.framework.*

suspend fun TestRunner.grafanaMonitoringTests() = suite("Grafana Monitoring Tests") {
test("Grafana server is healthy") {
        val response = client.getRawResponse("${env.endpoints.grafana}/api/health")
        response.status shouldBe HttpStatusCode.OK
        val body = response.bodyAsText()
        body shouldContain "ok"
    }

    test("Grafana login page loads") {
        val response = client.getRawResponse("${env.endpoints.grafana}/login")
        response.status shouldBe HttpStatusCode.OK
    }
}
