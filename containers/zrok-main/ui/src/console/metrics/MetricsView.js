import {Col, Container, Row} from "react-bootstrap";
import {bytesToSize} from "./util";
import {Area, AreaChart, CartesianGrid, ResponsiveContainer, XAxis, YAxis} from "recharts";
import moment from "moment/moment";
import React from "react";

const MetricsViews = (props) => {
    return (
        <Container>
            <Row>
                <Col>
                    <h3>Last 30 Days:</h3>
                </Col>
            </Row>
            <MetricsSummary metrics={props.metrics30} />
            <MetricsGraph metrics={props.metrics30} />
            <Row>
                <Col>
                    <h3>Last 7 Days:</h3>
                </Col>
            </Row>
            <MetricsSummary metrics={props.metrics7} />
            <MetricsGraph metrics={props.metrics7} />
            <Row>
                <Col>
                    <h3>Last 24 Hours:</h3>
                </Col>
            </Row>
            <MetricsSummary metrics={props.metrics1} />
            <MetricsGraph metrics={props.metrics1} />
        </Container>
    );
}

const MetricsSummary = (props) => {
    return (
        <Row>
            <Col><p>Received: {bytesToSize(props.metrics.rx)}</p></Col>
            <Col><p>Sent: {bytesToSize(props.metrics.tx)}</p></Col>
        </Row>
    );
}

const MetricsGraph = (props) => {
    return (
        <Row>
            <Col>
                <ResponsiveContainer width={"100%"} height={150}>
                    <AreaChart data={props.metrics.data}>
                        <CartesianGrid strokeDasharay={"3 3"} />
                        <XAxis dataKey={(v) => v.timestamp} scale={"time"} tickFormatter={(v) => moment(v).format("MMM DD") } style={{ fontSize: '75%'}}/>
                        <YAxis tickFormatter={(v) => bytesToSize(v)} style={{ fontSize: '75%' }}/>
                        <Area type={"basis"} stroke={"#231069"} fill={"#04adef"} dataKey={(v) => v.tx ? v.tx : 0} stackId={"1"} />
                        <Area type={"basis"} stroke={"#231069"} fill={"#9BF316"} dataKey={(v) => v.rx ? v.rx : 0} stackId={"1"} />
                    </AreaChart>
                </ResponsiveContainer>
            </Col>
        </Row>
    );
}

export default MetricsViews;