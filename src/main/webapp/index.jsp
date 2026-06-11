<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Read the submitted name from the GET query parameter (?name=...)
    String rawName = request.getParameter("name");
    String safeName = null;
    String greeting = null;

    if (rawName != null && !rawName.trim().isEmpty()) {
        // Sanitize the input to prevent XSS (cross-site scripting)
        safeName = rawName.trim()
                         .replace("&", "&amp;")
                         .replace("<", "&lt;")
                         .replace(">", "&gt;")
                         .replace("\"", "&quot;")
                         .replace("'", "&#x27;");
        greeting = "Hello, " + safeName + "! Your DevOps pipeline works.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MeTA DevOps Final Project</title>
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0d1117 0%, #161b22 50%, #0d1117 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            color: #c9d1d9;
        }

        /* ── HEADER ── */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 18px 40px;
            background: rgba(22, 27, 34, 0.9);
            border-bottom: 1px solid #30363d;
            backdrop-filter: blur(8px);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo {
            font-size: 1.6em;
            font-weight: 800;
            letter-spacing: 3px;
            color: #e94560;
        }
        .logo span { color: #f0f6fc; }

        nav { display: flex; gap: 6px; }

        nav a {
            color: #8b949e;
            text-decoration: none;
            font-size: 0.85em;
            padding: 6px 14px;
            border-radius: 6px;
            border: 1px solid transparent;
            transition: all 0.2s;
        }
        nav a:hover {
            color: #f0f6fc;
            border-color: #30363d;
            background: rgba(48, 54, 61, 0.5);
        }

        /* ── HERO ── */
        .hero {
            text-align: center;
            padding: 70px 20px 30px;
        }

        .badge {
            display: inline-block;
            font-size: 0.75em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 5px 14px;
            border-radius: 20px;
            color: #e94560;
            background: rgba(233, 69, 96, 0.1);
            border: 1px solid rgba(233, 69, 96, 0.35);
            margin-bottom: 24px;
        }

        h1 {
            font-size: clamp(2em, 5vw, 3.2em);
            font-weight: 800;
            color: #f0f6fc;
            line-height: 1.15;
            margin-bottom: 16px;
        }
        h1 .accent { color: #e94560; }

        .subtitle {
            font-size: 1.05em;
            color: #8b949e;
            max-width: 560px;
            margin: 0 auto 50px;
            line-height: 1.7;
        }
        .subtitle strong { color: #c9d1d9; }

        /* ── MAIN CARD ── */
        .container { max-width: 680px; margin: 0 auto; width: 90%; }

        .card {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 12px;
            padding: 36px;
            margin-bottom: 24px;
        }

        /* ── PIPELINE BADGES ── */
        .pipeline-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 28px;
        }
        .pill {
            font-size: 0.78em;
            padding: 4px 12px;
            border-radius: 20px;
            border: 1px solid #30363d;
            color: #58a6ff;
            background: rgba(88, 166, 255, 0.08);
        }

        /* ── FORM ── */
        .form-label {
            font-size: 0.9em;
            color: #8b949e;
            margin-bottom: 10px;
            display: block;
        }
        .form-label strong { color: #c9d1d9; }

        .form-row {
            display: flex;
            gap: 10px;
        }

        input[type="text"] {
            flex: 1;
            padding: 12px 16px;
            background: #0d1117;
            border: 1px solid #30363d;
            border-radius: 8px;
            color: #f0f6fc;
            font-size: 0.95em;
            outline: none;
            transition: border-color 0.2s;
        }
        input[type="text"]:focus { border-color: #58a6ff; }
        input[type="text"]::placeholder { color: #484f58; }

        button[type="submit"] {
            padding: 12px 24px;
            background: #e94560;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 0.95em;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: background 0.2s, transform 0.1s;
        }
        button[type="submit"]:hover  { background: #c83350; }
        button[type="submit"]:active { transform: scale(0.97); }

        /* ── GREETING ── */
        .greeting {
            margin-top: 20px;
            padding: 16px 20px;
            background: rgba(46, 160, 67, 0.1);
            border: 1px solid rgba(46, 160, 67, 0.4);
            border-radius: 8px;
            font-size: 1.05em;
            font-weight: 600;
            color: #3fb950;
            animation: slideIn 0.35s ease;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── INFO GRID ── */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            margin-bottom: 28px;
        }
        .info-box {
            background: #0d1117;
            border: 1px solid #21262d;
            border-radius: 8px;
            padding: 16px 12px;
            text-align: center;
        }
        .info-box .icon { font-size: 1.5em; margin-bottom: 6px; }
        .info-box .lbl  { font-size: 0.72em; color: #484f58; text-transform: uppercase; letter-spacing: 1px; }
        .info-box .val  { font-size: 0.95em; color: #f0f6fc; font-weight: 600; margin-top: 3px; }

        /* ── EXTERNAL LINK ── */
        .ext-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            margin-top: 18px;
            color: #8b949e;
            text-decoration: none;
            font-size: 0.88em;
            padding: 9px 18px;
            border: 1px solid #30363d;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .ext-link:hover { color: #58a6ff; border-color: #58a6ff; background: rgba(88, 166, 255, 0.05); }

        /* ── FOOTER ── */
        footer {
            margin-top: auto;
            padding: 20px;
            text-align: center;
            font-size: 0.82em;
            color: #484f58;
            border-top: 1px solid #21262d;
        }

        @media (max-width: 520px) {
            .form-row { flex-direction: column; }
            .info-grid { grid-template-columns: repeat(3, 1fr); }
            header { padding: 14px 20px; }
        }
    </style>
</head>
<body>

<!-- ================================================================ -->
<!-- HEADER                                                           -->
<!-- ================================================================ -->
<header>
    <div class="logo">Me<span>TA</span></div>
    <nav>
        <!-- REPLACE: update href to your actual GitHub repository URL -->
        <a href="https://github.com/YOUR_GITHUB_USERNAME/meta-devops-final-project"
           target="_blank" rel="noopener" id="github-link">GitHub</a>
        <a href="https://jenkins.io" target="_blank" rel="noopener" id="jenkins-link">Jenkins</a>
        <a href="https://gatling.io"  target="_blank" rel="noopener" id="gatling-link">Gatling</a>
    </nav>
</header>

<!-- ================================================================ -->
<!-- HERO                                                             -->
<!-- ================================================================ -->
<div class="hero">
    <div class="badge">&#9881; DevOps Final Project</div>
    <h1 id="main-title">MeTA DevOps <span class="accent">Final Project</span></h1>
    <p class="subtitle">
        A complete CI/CD pipeline demonstration by <strong>Alexander Morozov, Roei Shalom, and Yaron Miroluz</strong>.<br>
        Built with Maven &bull; Deployed via Jenkins &bull; Tested with Selenium &amp; Gatling.
    </p>
</div>

<!-- ================================================================ -->
<!-- MAIN CARD                                                        -->
<!-- ================================================================ -->
<div class="container">
    <div class="card">

        <!-- Pipeline stage badges (decorative) -->
        <div class="pipeline-badges">
            <span class="pill">&#9679; Checkout</span>
            <span class="pill">&#9679; Build WAR</span>
            <span class="pill">&#9679; Deploy</span>
            <span class="pill">&#9679; Restart</span>
            <span class="pill">&#9679; Availability</span>
            <span class="pill">&#9679; Selenium</span>
            <span class="pill">&#9679; Gatling</span>
        </div>

        <!-- Tech info boxes -->
        <div class="info-grid">
            <div class="info-box">
                <div class="icon">&#128230;</div>
                <div class="lbl">Build</div>
                <div class="val">Maven</div>
            </div>
            <div class="info-box">
                <div class="icon">&#128640;</div>
                <div class="lbl">CI / CD</div>
                <div class="val">Jenkins</div>
            </div>
            <div class="info-box">
                <div class="icon">&#128202;</div>
                <div class="lbl">Perf Test</div>
                <div class="val">Gatling</div>
            </div>
        </div>

        <!-- Name input form -->
        <label class="form-label" for="nameInput">
            Enter your name and click <strong>Run Pipeline</strong> to test the application:
        </label>

        <form method="get" action="">
            <div class="form-row">
                <input type="text"
                       id="nameInput"
                       name="name"
                       placeholder="Your name..."
                       value="<%= safeName != null ? safeName : "" %>"
                       autocomplete="off" />
                <button type="submit" id="submitBtn">Run Pipeline</button>
            </div>
        </form>

        <!-- Greeting — shown only after form is submitted with a name -->
        <% if (greeting != null) { %>
        <div class="greeting" id="greetingResult">
            &#9989; <%= greeting %>
        </div>
        <% } %>

    </div><!-- /card -->

    <!-- External link — satisfies "at least one link" requirement -->
    <a href="https://maven.apache.org" target="_blank" rel="noopener"
       class="ext-link" id="maven-link">
        &#128279; Apache Maven Official Website
    </a>

</div><!-- /container -->

<!-- ================================================================ -->
<!-- FOOTER                                                           -->
<!-- ================================================================ -->
<footer>
    &copy; 2024 MeTA Corporation &mdash; DevOps Final Project &mdash; Alexander Morozov &bull; Roei Shalom &bull; Yaron Miroluz
</footer>

</body>
</html>
