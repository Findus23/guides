import {MatomoLiteTracker} from "matomo-lite-tracker/src/tracker"
import {PerformanceMetric} from "matomo-lite-tracker/src/performancetracking"
import {BrowserFeatures} from "matomo-lite-tracker/src/browserfeatures"
import {enableLinkTracking} from "matomo-lite-tracker/src/linktracking"
import {isDoNotTrackEnabled} from "matomo-lite-tracker/src/util"

if (!isDoNotTrackEnabled()) {

    const m = new MatomoLiteTracker("https://matomo.lw1.at", 28)
    m.performanceMetric = new PerformanceMetric()

    m.browserFeatures = new BrowserFeatures()

    enableLinkTracking(m, [])
    m.trackPageview()
}

