package com.vaadin;

import com.vaadin.ui.NativeSelect;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 31.05.2017.
 */
public class tChildDetectorSelect extends NativeSelect {

    class DeviceIdName{
        Integer UserDeviceId;
        String UserDeviceName;

        DeviceIdName(
                Integer userDeviceId
                ,String userDeviceName
        ){
            UserDeviceId = userDeviceId;
            UserDeviceName = userDeviceName;
        }
    }

    List<DeviceIdName> ChildDetectors;


    public tChildDetectorSelect(tActuatorStatesLayout eActuatorStatesLayout){

        ChildDetectors = new ArrayList<>();

        Integer iParentLeafId = eActuatorStatesLayout
                .iParentContentLayout.GetParentLeafById(eActuatorStatesLayout.iCurrentLeafId);

        List<Integer> ChildLeafs = eActuatorStatesLayout
                .iParentContentLayout
                .getChildAllLeafsById(iParentLeafId);

        for (Integer iL : ChildLeafs) {
            String ChildLeafActionType = (String) eActuatorStatesLayout
                    .iParentContentLayout
                    .itTree
                    .TreeContainer.getItem(iL).getItemProperty(7).getValue();
            if (ChildLeafActionType.equals("Измерительное устройство")){
                Integer ChildUserDeviceId = eActuatorStatesLayout
                        .iParentContentLayout
                        .getLeafUserDeviceId(iL);
                String ChildUserDeviceName = eActuatorStatesLayout
                        .iParentContentLayout
                        .GetLeafNameById(iL);

                ChildDetectors.add(new DeviceIdName(ChildUserDeviceId,ChildUserDeviceName));
                addItem(ChildUserDeviceName);
            }
        }

    }

}