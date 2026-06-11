package meta.performance;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

/**
 * LOAD SIMULATION (5 minutes)
 *
 * Goal: Simulate a realistic steady-state load over 5 minutes.
 * This models normal production traffic to confirm the app handles
 * expected load without performance degradation.
 *
 * Profile:
 *   - 30-second warm-up: ramp from 1 to 10 users/sec
 *   - 4.5-minute steady state: constant 10 users/sec
 *   Total: exactly 300 seconds (5 minutes)
 *
 * Pass threshold:
 *   - 95th-percentile response time < 1 second
 *   - At least 95% of requests must succeed
 *
 * Run with:
 *   mvn gatling:test -Dgatling.simulationClass=meta.performance.LoadSimulation \
 *                    -Dapp.base.url=http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject
 */
public class LoadSimulation extends Simulation {

    private static final String BASE_URL = System.getProperty(
        "app.base.url", "http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject"
    );

    HttpProtocolBuilder httpProtocol = http
        .baseUrl(BASE_URL)
        .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        .acceptLanguageHeader("en-US,en;q=0.5")
        .acceptEncodingHeader("gzip, deflate")
        .userAgentHeader("Gatling Load Simulation/1.0");

    ScenarioBuilder scn = scenario("Load Test - 5 Minutes Steady State")
        .exec(
            http("GET Home Page")
                .get("/")
                .check(status().is(200))
                .check(substring("MeTA DevOps"))
        )
        .pause(1)
        .exec(
            http("GET Submit Name Form")
                .get("/?name=LoadTestUser")
                .check(status().is(200))
                .check(substring("Hello"))
        );

    {
        setUp(
            scn.injectOpen(
                rampUsersPerSec(1).to(10).during(30),     // 30s warm-up ramp
                constantUsersPerSec(10).during(270)        // 270s = 4.5min steady load
            )
        ).protocols(httpProtocol)
         .assertions(
             // 95th percentile response time must stay under 1 second
             global().responseTime().percentile(95).lt(1000),
             // At least 95% of all requests must return HTTP 200
             global().successfulRequests().percent().gt(95.0)
         );
    }
}
