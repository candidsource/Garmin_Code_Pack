create or replace directory DBMS_OPTIM_LOGDIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/cfgtoollogs';

create or replace directory DBMS_OPTIM_ADMINDIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/admin';

create or replace directory SDO_DIR_WORK as
'';

create or replace directory SDO_DIR_ADMIN as
'/u01/app/oracle/product/19.0.0/ORBUPG/md/admin';

create or replace directory XMLDIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/xml';

create or replace directory XSDDIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/xml/schema';

create or replace directory OPATCH_INST_DIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/OPatch';

create or replace directory ORACLE_BASE as
'/u01/app/oracle';

create or replace directory ORACLE_HOME as
'/u01/app/oracle/product/19.0.0/ORBUPG';

create or replace directory DATA_PUMP_DIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/log/38E86C20B8B78D30E0530A4F050AF2F5';

create or replace directory OPATCH_SCRIPT_DIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/QOpatch';

create or replace directory OPATCH_LOG_DIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/log';

create or replace directory JAVA$JOX$CUJS$DIRECTORY$ as
'/u01/app/oracle/product/19.0.0/ORBUPG/javavm/admin/';

create or replace directory EBS_UTL_FILE_DIR_7680332892077 as
'/austin/data/interface/ORBUPG/EDI/edi_outbound';

create or replace directory EBS_UTL_FILE_DIR_7934526042464 as
'/austin/data/interface/ORBUPG/EDI/edi_inbound';

create or replace directory EBS_UTL_FILE_DIR_5100925328183 as
'/u02/ORBUPG/APPLPTMP';

create or replace directory EBS_UTL_FILE_DIR_5552962257797 as
'/u01/app/oracle/product/19.0.0/temp/ORBUPG';

create or replace directory XX_DELTA_SEV_RECOVERY_PICK_DIR as
'/austin/data/interface/ORBUPG/DeltaSevRecovery/Pick';

create or replace directory XX_DELTA_SEV_REC_PICK_ARCH_DIR as
'/austin/data/interface/ORBUPG/DeltaSevRecovery/Pick/Archive';

create or replace directory XX_MFG_AOEM_SMT_DIR as
'/austin/data/MFG/AOEM/Production/SMT/PlacementPurchaseSelects';

create or replace directory EBS_APPLPTMP as
'/u02/ORBUPG/APPLPTMP';

create or replace directory PREUPGRADE_DIR as
'/u01/app/oracle/product/19.0.0/ORBUPG/rdbms/admin';

create or replace directory XX_ITEM_TRANS_DEF_PL1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/PL1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_PL1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/PL1/';

create or replace directory XX_ITEM_TRANS_DEF_FR1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/FR1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_FR1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/FR1/';

create or replace directory XX_ITEM_TRANS_DEF_BE1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/BE1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_BE1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/BE1/';

create or replace directory XX_MOVE_STMT_UPLOAD as
'/u02/ORBUPGg/GRMNtmp';

create or replace directory XX_BE_MOVE_STMT as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/BE/BANK_STATEMENTS';

create or replace directory VTX_TPE_FILE_DIR as
'/u02/ORBUPGg/vertex_o_series/TPE';

create or replace directory VTX_DIR as
'/u02/ORBUPG/vertex_tax_link/p2p_recon';

create or replace directory EBS_OUTBOUND as
'/u02/ORBUPG/GRMNtmp';

create or replace directory EBS_INBOUND as
'/u02/ORBUPG/GRMNtmp';

create or replace directory EBS_LOG as
'/u02/ORBUPG/GRMNtmp';

create or replace directory EBS_TEMP as
'/u02/ORBUPG/GRMNtmp';

create or replace directory XX_3PL_DIR as
'/austin/data/interface/ORBUPG/3PL';

create or replace directory TOAD_TRACEFILE_DIR_7 as
'/u01/app/oracle/diag/rdbms/orbupg/ORBUPG8/trace';

create or replace directory XX_ITEM_TRANS_DEF_G14_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G14/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_G14_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G14/';

create or replace directory XX_CZ_RET_STORE_ARCH as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/RETAIL/ARCHIVE';

create or replace directory XX_CZ_RETAIL_STORE as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/RETAIL';

create or replace directory XX_CZ_ADYEN_ARCH as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/ADYEN/ARCHIVE';

create or replace directory XX_CZ_ADYEN as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/ADYEN';

create or replace directory XX_CZ_UNICREDIT_ARCH as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/UNICREDIT/ARCHIVE';

create or replace directory XX_CZ_UNICREDIT as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/UNICREDIT';

create or replace directory XX_CE_STMT_BNP_DIR as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/PL/BANK_STATEMENTS';

create or replace directory UDUMP as
'/u01/app/oracle/product/12.1.0.2/ORBUPG/rdbms/log';

create or replace directory XX_CZ_BANK_STAT_ARCH as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS/ARCHIVE';

create or replace directory XX_CZ_BANK_STATEMENTS as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/CZ/BANK_STATEMENTS';

create or replace directory XX_WL_DIR as
'/austin/data/interface/ORBUPG/BANK_INTEGRATIONS/PL/SUPPLIER_BANK_WHITE_LISTS';

create or replace directory XX_PL_INV_FEED_DIR as
'/austin/data/interface/ORBUPG/Poland_Inventory/PL_Onhand';

create or replace directory XX_UK_INV_FEED_DIR as
'/austin/data/interface/ORBUPG/EMEA_Inventory_Visibility/UK_OnHand';

create or replace directory XX_MFG_SHOP_ORDER_REP_DIR_NEW as
'/austin/data/MFG/Shop_Order_Reports';

create or replace directory XX_DESPATCH_NOTE_FTP_DIR as
'/austin/data/interface/ORBUPG/DESPATCH_NOTE';

create or replace directory EBS_DB_DIR_UTIL as
'/u02/ORBUPG/GRMNtmp';

create or replace directory XX_ITEM_TRANS_DEF_NL1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/NL1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_NL1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/NL1/';

create or replace directory XX_FLAGSHIP_LBL_DIR as
'/austin/data/interface/ORBUPG/FLAGSHIP/Carrier';

create or replace directory XX_FLAGSHIP_INTL_DIR as
'/austin/data/interface/ORBUPG/FLAGSHIP/International';

create or replace directory XX_FLAGSHIP_DN_DIR as
'/austin/data/interface/ORBUPG/FLAGSHIP/DeliveryPackList';

create or replace directory XX_ITEM_TRANS_DEF_DE1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/DE1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_DE1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/DE1/';

create or replace directory XX_ITEM_TRANS_DEF_G1_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G1/Archive/';

create or replace directory XX_ITEM_TRANS_DEF_G1_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G1/';

create or replace directory XX_ITEM_TRANS_DEFAULT_BASE_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults';

create or replace directory XX_OA_MEDIA_DIR as
'/ORBUPG/app/applmgr/fs2/EBSapps/comn/java/classes/oracle/apps/media/';

create or replace directory XX_GLOBAL_RTG_DIR as
'/austin/data/interface/ORBUPG/Garmin_Routing_Upload';

create or replace directory XX_CONVERSIONS_HR_DIR as
'/austin/data/interface/ORBUPG/ADPTOORACLE/Concurrent';

create or replace directory XX_MFG_SHOP_ORDER_REP_DIR as
'/austin/data/interface/ORBUPG/Shop_Order_Reports';

create or replace directory XX_CUBISCAN_ARCH_DIR as
'/austin/data/interface/ORBUPG/Warehouse/Cubiscan/Archive';

create or replace directory TOAD_TRACEFILE_DIR_5 as
'/u01/app/oracle/diag/rdbms/orbupg/ORBUPG5/trace';

create or replace directory XX_RS_MO_DIR as
'/austin/data/interface/ORBUPG/Retail_Store';

create or replace directory XX_DELTA_PL_DIR as
'/olathe/warehouse/interface/ORBUPG/Pallet';

create or replace directory XX_MFG_ROUTING_UPD_ARCHIVE_DIR as
'/austin/data/interface/ORBUPG/MFG/Routing_Updates/Archive';

create or replace directory XX_MFG_ROUTING_UPD_DIR as
'/austin/data/interface/ORBUPG/MFG/Routing_Updates';

create or replace directory EPP_SHARED as
'/olathe/interface/shared/EPP/oraclebatteryib';

create or replace directory XX_DELTA_DN_DIR as
'/olathe/warehouse/interface/ORBUPG/DeliveryPackList';

create or replace directory XX_DELTA_INTL_DIR as
'/olathe/warehouse/interface/ORBUPG/International';

create or replace directory XX_ITEM_TRANS_DEFAULT_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G1/Archive';

create or replace directory XX_ITEM_TRANS_DEFAULT_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Tran_Defaults/G1';

create or replace directory XX_SMT_DATA_ARCH_DIR as
'/austin/data/interface/ORBUPG/MFG/SMT_Load_Sheets/ARCHIVE';

create or replace directory XX_SMT_DATA_DIR as
'/austin/data/interface/ORBUPG/MFG/SMT_Load_Sheets/PROCESS';

create or replace directory XX_WAREHOUSE_ITEM_EXTRACT_DIR as
'/austin/data/interface/ORBUPG/Delta Item Conversion';

create or replace directory XX_CONC_OUT as
'/ORBUPG-log/app/applmgr/logs/appl/conc/out';

create or replace directory XX_SII_AR as
'/austin/data/interface/ORBUPG/EDI/SII-TEMP/input/AR';

create or replace directory XX_SII_AP as
'/austin/data/interface/ORBUPG/EDI/SII-TEMP/input/AP';

create or replace directory XX_MTD_FOLDER as
'/austin/data/interface/ORBUPG/MTD/Tax_Register_Report';

create or replace directory XX_ITEM_PHYSICAL_ATT_ARCH_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Physical_Attributes/Archive';

create or replace directory XX_ITEM_PHYSICAL_ATT_DIR as
'/austin/data/interface/ORBUPG/Garmin_Item_Physical_Attributes';

create or replace directory XX_CSI_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/CSI';

create or replace directory XX_DELTA_PALLET_DIR as
'/olathe/warehouse/interface/ORBUPG/Pallet';

create or replace directory XX_DELTA_KISOFT_CONVERSION_DIR as
'/austin/data/interface/ORBUPG/Delta Kisoft On Hand Conversion/G1';

create or replace directory XX_CONSIGNOR as
'/austin/data/interface/';

create or replace directory XX_MINMAX_UPLOAD_DIR as
'/austin/data/interface/ORBUPG/MinMax_Upload/PROCESSING';

create or replace directory XX_CONVERSIONS_RSP_GRP_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/RESP_GROUP/PROCESSING';

create or replace directory APLIST as
'/mnt/nfs/oracle.patches/scripts/aplist';

create or replace directory XX_STAGING_NEW_USER_DIR as
'/austin/data/interface/ORBUPG/Post Clone User';

create or replace directory XX_QA_MRB as
'/austin/data/interface/ORBUPG/MRB_PDF';

create or replace directory XX_SN_MASS_UPD_DIR as
'/austin/data/interface/ORBUPG/SerialNumberReset';

create or replace directory XX_LOGOPAK_DESPATCH_NOTE_DIR as
'/uk/data/ORBUPGg/Despatch_Note';

create or replace directory XX_LOGOPAK_COURIER_LABEL_DIR as
'/uk/data/ORBUPGg/Courier_Label';

create or replace directory XX_RS_MO_ES1_DIR as
'/austin/data/interface/ORBUPG/Retail_Store/ES_Barcelona/Move_Order_ASN_Outbound';

create or replace directory XX_DHL_ECOM_DIR as
'/austin/data/interface/ORBUPG/DHL_Manifest';

create or replace directory DB_DPUMP as
'/usr/tmp';

create or replace directory XX_GDPR_CUST_MERGE_HST_DIR as
'/austin/data/interface/ORBUPG/GDPR/CustomerMerge/Archive';

create or replace directory XX_GDPR_CUST_MERGE_DIR as
'/austin/data/interface/ORBUPG/GDPR/CustomerMerge';

create or replace directory XX_GDPR_SHIPPING_PURGE_DIR as
'/austin/data/interface/ORBUPG/GDPR_SHIPPING_PURGE';

create or replace directory XX_EDICOM_RECIBO as
'/austin/data/interface/ORBUPG/EDI/EDICom_Mex/outbound/payment';

create or replace directory XX_EDICOM_ENVOICING as
'/austin/data/interface/ORBUPG/EDI/EDICom_Mex/outbound/invoice';

create or replace directory XX_CONVERSIONS_POS_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/EMPLOYEE/PROCESSING';

create or replace directory XX_CLONE_RESP_DIR as
'/austin/data/interface/ORBUPG/Post Clone Resp';

create or replace directory XX_CUBISCAN_DIR as
'/austin/data/interface/ORBUPG/Warehouse/Cubiscan';

create or replace directory XX_AUDIT_REPORT_DIR as
'/austin/data/interface/ORBUPG/AUDIT_REPORTS';

create or replace directory XX_CONVERSIONS_AR_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/AR/PROCESSING';

create or replace directory XX_CM_SO_SUB_DIR as
'/austin/data/interface/ORBUPG/CREDIT_MEMO/DE/PROCESSING';

create or replace directory XX_CM_SO_DIR as
'/austin/data/interface/ORBUPG/CREDIT_MEMO/DE';

create or replace directory XX_SALES_ORD_SUB_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/OM/PROCESSING';

create or replace directory XX_SALES_ORD_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/OM';

create or replace directory XX_CONVERSIONS_MTR_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/MENU_TRANS/PROCESSING';

create or replace directory XX_CONVERSIONS_CUS_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/CUSTOMER/PROCESSING';

create or replace directory XX_BANK_SUB_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/BANK/Files';

create or replace directory XX_BANK_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/BANK';

create or replace directory XX_SOA_KILL_SESSION as
'/mnt/nfs/oracle.patches/scripts/orbupg_mails_archive/ORBUPG/SOA_KILL_SESS_MAILS';

create or replace directory XX_MWA_KILL_SESSION as
'/mnt/nfs/oracle.patches/scripts/orbupg_mails_archive/ORBUPG/MWA_KILL_SESS_MAILS';

create or replace directory XX_GL_IFACE_OUT_DIR as
'/ORBUPG-log/app/applmgr/logs/appl/conc/out';

create or replace directory XX_GL_IFACE_DIR_ARCH as
'/austin/data/interface/ORBUPG/EngageIP/GL_Import/Archive';

create or replace directory XX_GL_IFACE_SUB_DIR as
'/austin/data/interface/ORBUPG/EngageIP/GL_Import';

create or replace directory XX_GL_IFACE_DIR as
'/austin/data/interface/ORBUPG/EngageIP';

create or replace directory XX_SPAIN_SEPA_DIR as
'/austin/data/interface/ORBUPG/Spain_SEPA';

create or replace directory XX_KANBAN_DIR as
'/austin/data/interface/ORBUPG/Garmin_Kanban_Upload';

create or replace directory XX_CONVERSIONS_PO_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/PO/PROCESSING';

create or replace directory XX_CONVERSIONS_SUP_DIR as
'/austin/data/interface/ORBUPG/CONVERSIONS/SUPPLIER/PROCESSING';

create or replace directory DATA_PUMP_DIR21 as
'/mnt/nfs/oracle.patches/data_pump_files';

create or replace directory SQLT$DIAG as
'/u01/app/oracle/diag/rdbms/orbupgcd/ORBUPG1/trace';

create or replace directory AR_WEB_INVOICE as
'/ar_web_invoice';

create or replace directory XX_BOM_DIR as
'/austin/data/interface/ORBUPG/Garmin_BOM_Upload';

create or replace directory EUL4_BACKUP as
'/ORADUMP/eul4_us_dpump';

create or replace directory TRACE_DIR_SRC_4_TCB as
'/u01/app/oracle/diag/rdbms/orbupgcd1/ORBUPG2/trace';

create or replace directory FND_DIAG_DIR as
'/u01/app/oracle/diag/rdbms/orbupg/ORBUPG1/trace/';

create or replace directory XX_STO_ENVOICING as
'/austin/data/interface/ORBUPG/EDI/EDICom_Mex/outbound/invoice';

create or replace directory XX_PO_DOCUMENT_OUT as
'/u02/ORBUPGg/GRMNtmp/XX_GLOBAL_PO';

create or replace directory AP_DK_PAY_FILE_DIR as
'/austin/data/interface/ORBUPG/AP_Payment_File/Denmark';

create or replace directory XX_SERV_PLAN_DIR as
'/austin/data/interface/ORBUPG/Service_Planning_Reports';

create or replace directory XX_ADP_TO_ORACLE_FAIL as
'/austin/data/interface/ORBUPG/ADPTOORACLE/Failed';

create or replace directory XX_ADP_TO_ORACLE_ARC as
'/austin/data/interface/ORBUPG/ADPTOORACLE/Processed';

create or replace directory AM_AGENT43_DIR as
'/usr/tmp';

create or replace directory XX_ADP_TO_ORACLE_DIR as
'/austin/data/interface/ORBUPG/ADPTOORACLE';

create or replace directory AM_AGENT42_DIR as
'/usr/tmp';

create or replace directory AM_AGENT41_DIR as
'/usr/tmp';

create or replace directory AM_AGENT40_DIR as
'/usr/tmp';

create or replace directory XX_NEW2_AU_LOCKBOX_DIR as
'/austin/data/interface/ORBUPG/AU_Westpac_Autolockbox/Outbound';

create or replace directory XX_PO_EMAIL_DIR as
'/austin/data/interface/ORBUPG/PO_TERMS_CONDITIONS/';

create or replace directory AM_AGENT39_DIR as
'/usr/tmp';

create or replace directory AM_AGENT33_DIR as
'/usr/tmp';

create or replace directory AM_AGENT32_DIR as
'/usr/tmp';

create or replace directory XX_COO_UPLOAD_DIR as
'/austin/data/interface/ORBUPG/COO_Upload';

create or replace directory XX_KANBAN_CARD_DIR as
'/austin/data/interface/ORBUPG/Garmin_KBN_Print';

create or replace directory AM_AGENT23_DIR as
'/usr/tmp';

create or replace directory AM_AGENT22_DIR as
'/usr/tmp';

create or replace directory EDI_DATA as
'/austin/data/interface/ORBUPG/EDI';

create or replace directory AM_AGENT104_DIR as
'/usr/tmp';

create or replace directory GARM_APPLPTMP as
'/u02/ORBUPGg/APPLPTMP';

create or replace directory GARM_TEMP as
'/u02/ORBUPG/GRMNtmp';

create or replace directory TRCA$INPUT2 as
'/u01/app/oracle/diag/rdbms/orbupgcd/ORBUPG1/trace';

create or replace directory SQLT$BDUMP as
'/u01/app/oracle/diag/rdbms/orbupgcd/ORBUPG1/trace';

create or replace directory TRCA$STAGE as
'/usr/tmp';

create or replace directory TRCA$INPUT1 as
'/u01/app/oracle/diag/rdbms/orbupgcd/ORBUPG1/trace';

create or replace directory AM_AGENT103_DIR as
'/usr/tmp';

create or replace directory AM_AGENT100_DIR as
'/usr/tmp';

create or replace directory XX_GLSCM_EFT_DIR as
'/austin/data/interface/ORBUPG/GLS_Commerce_EFT';

create or replace directory XX_UK_TNT_CARINT_ADIR as
'/austin/data/interface/ORBUPG/TNT_Archive';

create or replace directory XX_UK_TNT_CARINT_DIR as
'/austin/data/interface/ORBUPG/TNT_Integration';

create or replace directory GAR_ASN_RMA as
'/austin/data/interface/ORBUPG/Nuvifone/outbound/RMAorder';

create or replace directory AM_AGENT93_DIR as
'/usr/tmp';

create or replace directory AM_AGENT800_DIR as
'/usr/tmp';

create or replace directory AM_AGENT83_DIR as
'/usr/tmp';

create or replace directory AM_AGENT82_DIR as
'/usr/tmp';

create or replace directory AM_AGENT81_DIR as
'/usr/tmp';

create or replace directory AM_AGENT9_DIR as
'/usr/tmp';

create or replace directory AM_AGENT7_DIR as
'/usr/tmp';

create or replace directory DPUMP as
'/ORBUPG/oraarch01/ORBUPG';

create or replace directory VERTEX_DPUMP as
'/mnt/nfs/oracle.patches/scripts/vertex';

create or replace directory AM_AGENT6_DIR as
'/usr/tmp';

create or replace directory XX_EMAIL_TEMP as
'/u02/ORBUPGg/GRMNtmp';

create or replace directory XX_FOXCONN_DIR as
'/usr/tmp';

create or replace directory ROYALTY_EXCEPTION_DIR as
'/austin/data/interface/ORBUPG/royalties/exceptions';

create or replace directory XX_SEUR_MFST as
'/austin/data/interface/ORBUPG/SEUR.NEW';

create or replace directory AM_AGENT3_DIR as
'/usr/tmp';

create or replace directory EBS_LL_CONFIG_DIR as
'/u01/app/oracle/product/12.1.0.2/ORBUPG/ccr/state';

create or replace directory XX_GLCM_EFT_DIR as
'/austin/data/interface/ORBUPG/GL_Commerce_EFT';

create or replace directory XX_DCICM_EFT_DIR as
'/austin/data/interface/ORBUPG/DCI_Commerce_EFT';

create or replace directory XX_GICM_EFT_DIR as
'/austin/data/interface/ORBUPG/GI_Commerce_EFT';

create or replace directory AM_AGENT14_DIR as
'/usr/tmp';

create or replace directory AM_AGENT1_DIR as
'/usr/tmp';

create or replace directory USR_TMP_DIR as
'/u02/ORBUPGg/GRMNtmp';

create or replace directory XX_WESTPAC_EFT_DIR as
'/austin/data/interface/ORBUPG/AU_Westpac_EFT';

create or replace directory AM_AGENT281_DIR as
'/usr/tmp';

create or replace directory AM_AGENT12_DIR as
'/usr/tmp';

create or replace directory XX_POS_PAY_DIR as
'/austin/data/interface/ORBUPG/Positive_Pay/GI_CheckingAccount/';

create or replace directory ECX_UTL_XSLT_DIR_OBJ as
'/usr/tmp';

create or replace directory ECX_UTL_LOG_DIR_OBJ as
'/usr/tmp';

create or replace directory CCG_AGENT_DIR as
'/u02/ORBUPGg/GRMNtmp';

create or replace directory WORK_DIR as
'/ORBUPG/oracle/product/10.2.0/work';

create or replace directory EXPDIR_EXP as
'/SUPERDUMP1/dmpfiles/ORBUPG';

create or replace directory EXP_LOG_DIR as
'/austin/data/interface/ORBUPG/xlogistics';

create or replace directory TRCA$UDUMP as
'/u01/app/oracle/diag/rdbms/orbupg/ORBUPG1/trace';

create or replace directory SQLT$UDUMP as
'/u01/app/oracle/diag/rdbms/orbupgcd/ORBUPG1/trace';

create or replace directory SQLT$STAGE as
'/usr/tmp';

create or replace directory AM_AGENT25_DIR as
'/usr/tmp';

create or replace directory GARM_DATA as
'/ORBUPG/app/applmgr/fs_ne/common/ORBUPGiface';

create or replace directory AM_AGENT2_DIR as
'/usr/tmp';

create or replace directory EXT_DIR as
'/d01/app/applmgr';

create or replace directory VLM_DIR as
'/usr/tmp';

create or replace directory EXCEL_OUTPUT as
'/austin/data/interface/ORBUPG/exceloutput';

create or replace directory AM_AGENT_DIR as
'/usr/tmp';

create or replace directory AM_AGENT280_DIR as
'/usr/tmp';

create or replace directory CCMGR_OUT as
'/ORBUPG/applmgr/ORBUPGcomn/admin/out/ORBUPG_uxmal';

create or replace directory DMPDIR_MIG as
'/SUPERDUMP1/dmpfiles/ORBUPG';

create or replace directory CCMGR_LOG as
'/ORBUPG/applmgr/ORBUPGcomn/admin/log/ORBUPG_uxmal';
