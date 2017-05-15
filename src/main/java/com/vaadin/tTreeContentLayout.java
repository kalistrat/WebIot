package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.ui.VerticalLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 13.01.2017.
 */
public class tTreeContentLayout extends VerticalLayout {

    tTree itTree;
    String iUserLog;

    public tTreeContentLayout(String tUserLog,tTree etTree){

        this.itTree = etTree;
        this.iUserLog = tUserLog;
        this.addComponent(new tFolderLayout(1,this));


    }

    public void tTreeContentLayoutRefresh(int eLeafId, int eUserDeviceId){
        this.removeAllComponents();
        if (eUserDeviceId == 0){
            this.addComponent(new tFolderLayout(eLeafId,this));
        } else {
            this.addComponent(new tDeviceLayout(eLeafId,this));
        }
        itTree.select(eLeafId);
    }

    public String GetLeafNameById(int eLeafId){

        return (String) this.itTree.getItem(eLeafId).getItemProperty(4).getValue();

    }

    public List<Integer> GetChildLeafsById(int eLeafId){
        List<Integer> iChildLeafs = new ArrayList<Integer>();

        for (int i=0;i<this.itTree.TreeContainer.size();i++) {
            Integer iParentLeafId = (Integer) this.itTree.getItem(i + 1).getItemProperty(3).getValue();
         if (iParentLeafId.equals(eLeafId)){
             iChildLeafs.add((Integer) this.itTree.getItem(i + 1).getItemProperty(2).getValue());
         }
        }

        return iChildLeafs;
    }

    public Integer GetParentLeafById(int eLeafId){
        Integer iParentLeafId = (Integer) this.itTree.getItem(eLeafId).getItemProperty(3).getValue();
        if (iParentLeafId == null) {
            return 0;
        } else {
            return iParentLeafId;
        }
    }

    public void setNewLeafName(int eLeafId,String eNewLeafName){

        this.itTree.getItem(eLeafId).getItemProperty(4).setValue(eNewLeafName);

    }

    public String getLeafIconCode(int eLeafId){

        return (String) this.itTree.getItem(eLeafId).getItemProperty(5).getValue();

    }

    public List<Integer> getChildAllLeafsByList(List<Integer> eParentLeafIds){

        List<Integer> PrevList = eParentLeafIds;

            for (int i = 0; i < eParentLeafIds.size(); i++) {
                for (int j = 0; j < GetChildLeafsById(eParentLeafIds.get(i)).size(); j++) {
                    PrevList.add(GetChildLeafsById(eParentLeafIds.get(i)).get(j));
                }
            }

        if (PrevList.size() != eParentLeafIds.size()) {
            return getChildAllLeafsByList(PrevList);
        } else {
            return PrevList;
        }

    }

    public List<Integer> getChildAllLeafsById(int LeafId){
        return getChildAllLeafsByList(GetChildLeafsById(LeafId));
    }

}
