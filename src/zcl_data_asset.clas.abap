CLASS zcl_data_asset DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DATA_ASSET IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


  DATA: lt_assets TYPE STANDARD TABLE OF zasset WITH EMPTY KEY.

    TRY.
        " Prepare test data for zasset with numeric external_id
        lt_assets = VALUE #(
          ( client = sy-mandt zz_pbukr = '1000' external_id = '1'
            zz_proj_manager = 'PMGR001' assetclass = 'LAPTOP'
            assetclassdes = 'Laptop/Notebook Asset' aktiv = '20240115'
            zz_kostl_resp = 'IT1001' anlhtxt = 'Dell Latitude 7430'
            changed_by = sy-uname
            local_last_changed_at = cl_abap_context_info=>get_system_time( )
            changed_at = cl_abap_context_info=>get_system_time( ) )

          ( client = sy-mandt zz_pbukr = '2000' external_id = '2'
            zz_proj_manager = 'PMGR002' assetclass = 'CHAIR'
            assetclassdes = 'Ergonomic Office Chair' aktiv = '20240310'
            zz_kostl_resp = 'AD2002' anlhtxt = 'Herman Miller Chair'
            changed_by = sy-uname
            local_last_changed_at = cl_abap_context_info=>get_system_time( )
            changed_at = cl_abap_context_info=>get_system_time( ) )

          ( client = sy-mandt zz_pbukr = '3000' external_id = '3'
            zz_proj_manager = 'PMGR003' assetclass = 'MONITOR'
            assetclassdes = '27-inch LED Monitor' aktiv = '20240201'
            zz_kostl_resp = 'IT1003' anlhtxt = 'Dell UltraSharp U2723QE'
            changed_by = sy-uname
            local_last_changed_at = cl_abap_context_info=>get_system_time( )
            changed_at = cl_abap_context_info=>get_system_time( ) )
        ).

        " Clean old records and insert new test data
        DELETE FROM zasset.
        INSERT zasset FROM TABLE @lt_assets.

        out->write( |{ sy-dbcnt } entries inserted into zasset.| ).

        COMMIT WORK.

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
