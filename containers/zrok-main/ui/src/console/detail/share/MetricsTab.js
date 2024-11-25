import React, {useEffect, useState} from "react";
import {buildMetrics} from "../../metrics/util";
import * as metadata from "../../../api/metadata";
import MetricsView from "../../metrics/MetricsView";

const MetricsTab = (props) => {
    const [metrics30, setMetrics30] = useState(buildMetrics([]));
    const [metrics7, setMetrics7] = useState(buildMetrics([]));
    const [metrics1, setMetrics1] = useState(buildMetrics([]));

    useEffect(() => {
        if(props.share.token) {
            metadata.getShareMetrics(props.share.token)
                .then(resp => {
                    setMetrics30(buildMetrics(resp.data));
                });
            metadata.getShareMetrics(props.share.token, {duration: "168h"})
                .then(resp => {
                    setMetrics7(buildMetrics(resp.data));
                });
            metadata.getShareMetrics(props.share.token, {duration: "24h"})
                .then(resp => {
                    setMetrics1(buildMetrics(resp.data));
                });
        }
    }, [props.share]);

    useEffect(() => {
        let mounted = true;
        let interval = setInterval(() => {
            if(props.share.token) {
                metadata.getShareMetrics(props.share.token)
                    .then(resp => {
                        if(mounted) {
                            setMetrics30(buildMetrics(resp.data));
                        }
                    });
                metadata.getShareMetrics(props.share.token, {duration: "168h"})
                    .then(resp => {
                        if(mounted) {
                            setMetrics7(buildMetrics(resp.data));
                        }
                    });
                metadata.getShareMetrics(props.share.token, {duration: "24h"})
                    .then(resp => {
                        if(mounted) {
                            setMetrics1(buildMetrics(resp.data));
                        }
                    });
            }
        }, 5000);
        return () => {
            mounted = false;
            clearInterval(interval);
        }
    }, [props.share]);

    return (
        <MetricsView metrics30={metrics30} metrics7={metrics7} metrics1={metrics1} />
    );
}

export default MetricsTab;