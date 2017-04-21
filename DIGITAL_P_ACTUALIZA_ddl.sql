CREATE OR REPLACE 
PROCEDURE p_actualiza IS
  cursor c is
    select CNS_TIPODOC1,  CNS_NROTRA1
      from digital.ne2010_4;
      
  v_encuentra     number;
  v_nrotra        varchar2(255):='';
  v_nrotra1       varchar2(255):='';
  v_ntra          varchar2(255):='';
  v_similares     number := 0;
  v_aperturas     number := 0;
  v_secuencia     number := 0;
  
begin
  
  for r in c loop
     v_nrotra := SUBSTR(r.cns_nrotra1,11);
     v_nrotra1 := r.cns_nrotra1;
     v_secuencia:= v_secuencia +1 ;
    select count(*)
      into v_encuentra
      from t2010_41 a
     where a.PR=r.CNS_TIPODOC1 AND a.NROTRA1 like '%'||v_nrotra||'%';    
     

    if v_encuentra = 1 then
        v_similares := v_similares + 1;
        dbms_output.put_line('Similares: '||r.cns_nrotra1);
        select NROTRA1
        into v_NTRA
        from t2010_41 b 
        where b.PR=r.CNS_TIPODOC1 AND b.NROTRA1 like '%'||v_nrotra||'%';    
    
        --update relacion_otro 
        --set cns_nrotra1 = v_NTRA
        --where cns_nrotra1 = v_nrotra;
        --commit;
      
    else
      dbms_output.put_line('No encuentra smilares: '||r.cns_nrotra1);
      v_aperturas := v_aperturas + 1;

      end if;
  end loop;

  
  dbms_output.put_line('Total Similares: '||v_similares);
  dbms_output.put_line('Total No encontrados: '||v_aperturas);
  dbms_output.put_line('Total Registros encontrados: '||v_secuencia);
  END;
/

