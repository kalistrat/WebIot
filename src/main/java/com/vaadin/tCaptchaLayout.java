package com.vaadin;

import com.vaadin.ui.VerticalLayout;
import org.vaadin.hezamu.canvas.Canvas;

import java.util.Random;

/**
 * Created by kalistrat on 14.06.2017.
 */
public class tCaptchaLayout extends VerticalLayout {

    Canvas canvas;

    public tCaptchaLayout(){

        canvas = new Canvas();
        int capWidth = 120;
        int capHeight = 50;

        canvas.setWidth(String.valueOf(capWidth) + "px");
        canvas.setHeight(String.valueOf(capHeight) + "px");

        canvas.beginPath();
        canvas.setLineWidth(2);
        canvas.setStrokeStyle("white");

        canvas.moveTo(0, 0);
        canvas.lineTo(0, capHeight);
        canvas.lineTo(capWidth, capHeight);
        canvas.lineTo(capWidth, 0);
        canvas.lineTo(0, 0);

        canvas.stroke();
        canvas.closePath();

        int ca = genRandInt(1,99);
        int cb = genRandInt(1,99);
        String csign = genSign();

        canvas.setFont("italic bold 25px sans-serif");
        canvas.setFillStyle("red");
        canvas.fillText(String.valueOf(ca),15,Math.round(0.5*capHeight) + 10,100);
        canvas.fillText(csign,45,Math.round(0.5*capHeight) + 10,100);
        canvas.fillText(String.valueOf(cb),60,Math.round(0.5*capHeight) + 10,100);



        this.addComponent(canvas);
        this.setSizeUndefined();

    }

    public int genRandInt(int mii,int mai){
        Random rnd = new Random(System.currentTimeMillis());
        int number = mii + rnd.nextInt(mai - mii + 1);
        rnd = null;
        System.gc();

        return  number;
    }

    public String genSign() {
        Random rnds = new Random(System.currentTimeMillis());
        int SignNum = 1 + rnds.nextInt(3);
        rnds = null;
        System.gc();
        System.out.println("SignNum : " + SignNum);

        switch (SignNum) {
            case 1 : return "+";
            case 2 : return "-";
            case 3 : return "*";
            //case 4 : return ":";
            default: return  "+";
        }

    }
}
