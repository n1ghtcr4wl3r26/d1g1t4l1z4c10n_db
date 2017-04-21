CREATE OR REPLACE TRIGGER trg_digital_logs_id
 BEFORE
  INSERT
 ON digital_logs
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
begin
if :NEW."LOG_ID" is null then
select "SEQ_TIM_LOGS".nextval into :NEW."LOG_ID" from dual;
end if;
end;
/

