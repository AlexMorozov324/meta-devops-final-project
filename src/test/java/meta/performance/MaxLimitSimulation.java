package meta.performance;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

/**
 * MAX LIMIT SIMULATION
 *
 * Goal: Find the application's breaking point by ramping traffic from
 * 1 user/sec up to 200 users/sec over 5 minutes.
 *
 * How to interpret the report:
 *   - Watch where response time starts climbing sharply
 *   - Watch where error rate starts rising above 0%
 *   - The point just before that is your practical max capacity
 *
 * Run with:
 *   mvn gatling:test -Dgatling.simulationClass=meta.performance.MaxLimitSimulation \
 *                    -Dapp.base.url=http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject
 */
public class MaxLimitSimulation extends Simulation {

    // Read app URL from Maven -D property, fallback to localhost
    private static final String BASE_URL = System.getProperty(
        "app.base.url", "http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject"
    );

    // HTTP protocol shared by all requests in this simulation
    HttpProtocolBuilder httpProtocol = http
        .baseUrl(BASE_URL)
        .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        .acceptLanguageHeader("en-US,en;q=0.5")
        .acceptEncodingHeader("gzip, deflate")
        .userAgentHeader("Gatling MaxLimit Simulation/1.0");

    // Scenario: two requests — home page and a form submission
    ScenarioBuilder scn = scenario("Max Limit - Find Breaking Point")
        .exec(
            http("GET Home Page")
                .get("/")
                .check(status().is(200))
                .check(substring("MeTA DevOps"))
        )
        .pause(1)
        .exec(
            http("GET Submit Name")
                .get("/?name=MaxLimitUser")
                .check(status().is(200))
                .check(substring("Hello"))
        );

    // Injection profile: ramp from 1 to 200 users/sec over exactly 5 minutes
    // The report will show at what point performance degrades — that is the max limit
    {
        setUp(
            scn.injectOpen(
                rampUsersPerSec(1).to(200).during(300)   // 5 minutes ramp-up
            )
        ).protocols(httpProtocol);
        // No assertions on purpose: we want to observe, not enforce a threshold
    }
}
