-- =============================================================================
-- DMZ / Middleware Proxy Database: Outbox Poller & Dispatcher
-- Security Invariant: The Proxy DB (in DMZ/Middleware) acts as the outbound actor.
-- It pulls pending events from Core DB, performs external HTTP / Kafka calls,
-- and acknowledges back to Core DB. Core DB never makes outbound sockets.
-- =============================================================================

CREATE OR REPLACE PACKAGE pkg_proxy_outbox_dispatcher AS
    -- Main polling procedure executed on schedule by DBMS_SCHEDULER
    PROCEDURE poll_and_dispatch;
    
    -- Dispatches single event to external REST endpoint or Kafka bridge
    PROCEDURE dispatch_single_event(
        p_event_id     IN NUMBER,
        p_topic_name   IN VARCHAR2,
        p_payload_json IN CLOB
    );
END pkg_proxy_outbox_dispatcher;
/

CREATE OR REPLACE PACKAGE BODY pkg_proxy_outbox_dispatcher AS

    PROCEDURE dispatch_single_event(
        p_event_id     IN NUMBER,
        p_topic_name   IN VARCHAR2,
        p_payload_json IN CLOB
    ) IS
        l_http_status   NUMBER := 200;
        l_response_clob CLOB;
    BEGIN
        -- Example dispatch using APEX_WEB_SERVICE or UTL_HTTP to Kafka REST Proxy or API Gateway
        -- Note: In proxy DB, outbound traffic is permitted by firewall rules.
        /*
        l_response_clob := APEX_WEB_SERVICE.make_rest_request(
            p_url         => 'https://kafka-rest-proxy.internal.corp:8082/topics/' || p_topic_name,
            p_http_method => 'POST',
            p_body        => p_payload_json,
            p_wallet_path => 'file:/opt/oracle/wallet',
            p_wallet_pwd  => NULL
        );
        l_http_status := APEX_WEB_SERVICE.g_status_code;
        */

        -- Simulated successful dispatch
        IF l_http_status BETWEEN 200 AND 299 THEN
            -- Acknowledge success to Core DB via DB Link or REST service:
            -- pkg_outbox@CORE_DB_LINK.mark_published(p_event_id);
            NULL;
        ELSE
            -- Record failure:
            -- pkg_outbox@CORE_DB_LINK.mark_failed(p_event_id, 'HTTP Error ' || l_http_status);
            NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- pkg_outbox@CORE_DB_LINK.mark_failed(p_event_id, SQLERRM);
            RAISE;
    END dispatch_single_event;

    PROCEDURE poll_and_dispatch IS
    BEGIN
        -- Query pending records from Core DB via secure private DB Link or ORDS
        -- Cursor over CORE_DB.outbox_events WHERE status = 'PENDING'
        NULL;
    END poll_and_dispatch;

END pkg_proxy_outbox_dispatcher;
/

-- =============================================================================
-- DBMS_SCHEDULER Setup in Proxy DB
-- Executes poll_and_dispatch every 10 seconds without blocking Core DB
-- =============================================================================
BEGIN
    -- Remove existing job if present
    BEGIN
        DBMS_SCHEDULER.DROP_JOB('JOB_PROXY_OUTBOX_DISPATCHER', TRUE);
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_PROXY_OUTBOX_DISPATCHER',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pkg_proxy_outbox_dispatcher.poll_and_dispatch; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=SECONDLY; INTERVAL=10',
        enabled         => TRUE,
        comments        => 'Polls Core DB Outbox and dispatches external REST/Kafka events from DMZ Proxy DB'
    );
END;
/
