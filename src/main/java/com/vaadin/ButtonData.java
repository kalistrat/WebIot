package com.vaadin;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 17.01.2017.
 */
public class ButtonData {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    Integer bdLeafId;
    Integer bdUserDeviceId;
    String bdUserLog;
    String bdIconCode;
    String bdLeafName;

    public ButtonData(int eTreeId){

        List<String> StrPieces = new ArrayList<String>();
        String BDResult = this.GetButtonData(eTreeId);
        int k = 0;

        while (!BDResult.equals("")) {
            int Pos = BDResult.indexOf("/");
            StrPieces.add(BDResult.substring(0,Pos));
            BDResult = BDResult.substring(Pos+1);
            k = k + 1;
            if (k>100){
                BDResult = "";
            }
        }

        this.bdLeafId = Integer.valueOf(StrPieces.get(0));
        this.bdUserDeviceId = Integer.valueOf(StrPieces.get(1));
        this.bdUserLog = StrPieces.get(2);
        this.bdIconCode = StrPieces.get(3);
        this.bdLeafName = StrPieces.get(4);

    }

    private String GetButtonData(int iTreeId){
        String iBDResult = "";

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement BDStmt = conn.prepareCall("{? = call f_get_button_data(?)}");
            BDStmt.registerOutParameter (1, Types.VARCHAR);
            BDStmt.setInt(2, iTreeId);
            BDStmt.execute();
            iBDResult = BDStmt.getString(1);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();
        }

        return iBDResult;
    }

}
