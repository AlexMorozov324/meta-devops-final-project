package meta.performance;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

/**
 * STRESS SIMULATION (5 minutes)
 *
 * Goal: Push the application beyond normal limits using an escalating
 * wave pattern. This reveals how the app degrades under heavy load
 * and whether it recovers after spikes.
 *
 * Wave profile (each wave = 1 minute):
 *   Wave 1 — Ramp: 0 → 20 users/sec in 60s
 *   Wave 2 — Hold: constant 20 users/sec for 60s
 *   Wave 3 — Spike: ramp 20 → 60 users/sec in 60s
 *   Wave 4 — Hold: constant 60 users/sec for 60s
 *   Wave 5 — Peak: ramp 60 → 120 users/sec in 60s
 *   Total: 300 seconds = 5 minutes
 *
 * Pass threshold:
 *   - 95th-percentile response time < 3 seconds (relaxed for stress)
 *   - At least 80% of requests must succeed
 *
 * Run with:
 *   mvn gatling:test -Dgatling.simulationClass=meta.performance.StressSimulation \
 *                    -Dapp.base.url=http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject
 */
public class StressSimulation extends Simulation {

    private static final String BASE_URL = System.getProperty(
        "app.base.url", "http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject"
    );

    HttpProtocolBuilder httpProtocol = http
        .baseUrl(BASE_URL)
        .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        .acceptLanguageHeader("en-US,en;q=0.5")
        .acceptEncodingHeader("gzip, deflate")
        .userAgentHeader("Gatling Stress Simulation/1.0");

    ScenarioBuilder scn = scenario("Stress Test - 5-Minute Escalating Waves")
        .exec(
            http("GET Home Page")
                .get("/")
                .check(status().is(200))
                .check(substring("MeTA DevOps"))
        )
        .pause(1)
        .exec(
            http("GET Submit Name Form")
                .get("/?name=StressTestUser")
                .check(status().is(200))
                .check(substring("Hello"))
        );

    {
        setUp(
            scn.injectOpen(
                // Wave 1: Ramp up to 20 users/sec
                rampUsersPerSec(1).to(20).during(60),
                // Wave 2: Hold 20 users/sec
                constantUsersPerSec(20).during(60),
                // Wave 3: Ramp up to 60 users/sec (spike!)
                rampUsersPerSec(20).to(60).during(60),
                // Wave 4: Hold 60 users/sec
                constantUsersPerSec(60).during(60),
                // Wave 5: Ramp up to 120 users/sec (peak stress!)
                rampUsersPerSec(60).to(120).during(60)
            )
        ).protocols(httpProtocol)
         .assertions(
             // Under stress, allow up to 3 seconds at 95th percentile
             global().responseTime().percentile(95).lt(3000),
             // At least 80% of requests must succeed even under heavy load
             global().successfulRequests().percent().gt(80.0)
         );
    }
}
