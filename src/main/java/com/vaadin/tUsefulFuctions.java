package com.vaadin;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 24.01.2017.
 */
public class tUsefulFuctions {

    static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final String DB_URL = "jdbc:mysql://localhost/things";
    static final String USER = "kalistrat";
    static final String PASS = "045813";

    public static List<String> GetListFromString(String DevidedString){
        List<String> StrPieces = new ArrayList<String>();
        int k = 0;
        String iDevidedString = DevidedString;

        while (!iDevidedString.equals("")) {
            int Pos = iDevidedString.indexOf("/");
            StrPieces.add(iDevidedString.substring(0, Pos));
            iDevidedString = iDevidedString.substring(Pos + 1);
            k = k + 1;
            if (k > 100000) {
                iDevidedString = "";
            }
        }

        return StrPieces;
    }

    public static List<tMark> GetMarksFromString(String MarksString,String AxeTitle){
        List<tMark> MarksList = new ArrayList<tMark>();
        List<String> MarksPairs = GetListFromString(MarksString);
        for (String sPair : MarksPairs){
            int iPos = sPair.indexOf("#");
            if (AxeTitle.equals("x")) {
                tMark tPair = new tMark(Integer.parseInt(sPair.substring(iPos+1)),0,sPair.substring(0, iPos));
                MarksList.add(tPair);
            } else {
                tMark tPair = new tMark(0,Integer.parseInt(sPair.substring(iPos+1)),sPair.substring(0, iPos));
                MarksList.add(tPair);
            }
        }
        return MarksList;
    }

    public static List<String> GetCaptionList(List<tIdCaption> eIdCaptionList){
        List<String> iIdCaptionList = new ArrayList<String>();
        for (tIdCaption iIdC : eIdCaptionList){
            iIdCaptionList.add(iIdC.tCaption);
        }
        return iIdCaptionList;
    }

    public static Integer GetIdByCaption(List<tIdCaption> eIdCaptionList,String eCaption){
        Integer iId = null;
        for (tIdCaption iIdC : eIdCaptionList){
            if (iIdC.tCaption.equals(eCaption)){
                iId = iIdC.tId;
            }
        }

        return iId;
    }

    public static Double GetDoubleFromString(String Val){
        Double dVal = null;
        if ((Val != null) || (!Val.equals(""))) {
            dVal = Double.parseDouble(Val.replace(",", "."));
        }
        return dVal;
    }

    public static Double ParseDouble(String strNumber) {
        if (strNumber != null && strNumber.length() > 0) {
            try {
                return Double.parseDouble(strNumber.replace(",", "."));
            } catch(Exception e) {
                return null;   // or some value to mark this field is wrong. or make a function validates field first ...
            }
        }
        else return null;
    }

    public static int fIsLeafNameBusy(String qUserLog,String qNewLeafName){
        int IsBusy = 0;

        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement LeafNameBusyStmt = Con.prepareCall("{? = call fIsLeafNameExists(?, ?)}");
            LeafNameBusyStmt.registerOutParameter (1, Types.INTEGER);
            LeafNameBusyStmt.setString(2, qUserLog);
            LeafNameBusyStmt.setString(3, qNewLeafName);
            LeafNameBusyStmt.execute();
            IsBusy = LeafNameBusyStmt.getInt(1);
            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

        return IsBusy;
    }

    public static void deleteUserDevice(
            String qUserLog
            ,int qLeafId
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement deleteDeviceStmt = Con.prepareCall("{call p_delete_user_device(?, ?)}");
            deleteDeviceStmt.setString(1, qUserLog);
            deleteDeviceStmt.setInt(2, qLeafId);
            deleteDeviceStmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }

    public static void deleteTreeLeaf(
            String qUserLog
            ,int qLeafId
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement deleteLeafStmt = Con.prepareCall("{call p_delete_tree_leaf(?, ?)}");
            deleteLeafStmt.setString(1, qUserLog);
            deleteLeafStmt.setInt(2, qLeafId);
            deleteLeafStmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }

    public static void refreshUserTree(
            String qUserLog
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement treeStmt = Con.prepareCall("{call p_refresh_user_tree(?)}");
            treeStmt.setString(1, qUserLog);
            treeStmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }
}
