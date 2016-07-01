package com.example.luke.m2m;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.Html;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import m2m.app.api.weavedapi;
//C:\Users\luke\AndroidStudioProjects\m2m\javaapiv2\src\main\java\m2m\app\api
//import m2m.app.api.*;

public class monitorControl extends ActionBarActivity {
    private TextView myText = null;
    TextView data;
    int index;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_monitor_control);
       /* Spinner dropdown = (Spinner)findViewById(R.id.spinner);
        String[] items = new String[]{"1", "2", "three"};
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, items);
        dropdown.setAdapter(adapter);*/
        data = (TextView) findViewById(R.id.textView);


/*\\
        //doesn't work :/
        weavedapi WeavedAPI = new weavedapi();
        WeavedAPI.login("siddhesh.singh@utdallas.edu", "newpass2");
        WeavedAPI.setup(false);
        WeavedAPI.setPiCreds(0, "webiopi","raspberry");
        WeavedAPI.genPiProxy(0);
        WeavedAPI.setupPi(0, false, "");
        System.out.println(WeavedAPI.getPiInfoArray().get(0).alias()); */
    }

    //Set text method
    protected void setText(String s){
        data =  (TextView) findViewById(R.id.textView);
        data.setText(s);
    }

    //Set's Toast Message
    protected void setToast(String s){
        Toast toast = Toast.makeText(getApplicationContext(), s, Toast.LENGTH_LONG);
        toast.show();
    }

    public void selectIndex(View view) {
        EditText mEdit   = (EditText)findViewById(R.id.editText3);
        String temp =mEdit.getText().toString();
        if(!temp.equals("")) {
            index = Integer.parseInt(mEdit.getText().toString());
            setText("Retrieving Data");


            new contactWeavedAPI().execute();
        }
        else{
            setToast("Please Select an Index");
        }


    }


    //Asyncronous Task to Download Web info
    private class contactWeavedAPI extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... urls) {
            String response = "";

            try {
                weavedapi WeavedAPI = new weavedapi();
                WeavedAPI.login("siddhesh.singh@utdallas.edu", "newpass2");
                WeavedAPI.setup(false);
                WeavedAPI.setPiCreds(index, "webiopi", "raspberry");
                WeavedAPI.genPiProxy(index);
                WeavedAPI.setupPi(index, false, "");
                response = WeavedAPI.exportPiJSON(index);
            } catch (Exception e) {
                e.printStackTrace();
                return "Error: " + e.getMessage();
            }

            return response;
        }

        @Override
        //Author:Luke New
        //Sets text after downloading.
        protected void onPostExecute(String result) {
            //setToast("Downloading...");
            String[] eh = result.split("number");
            String ret = "";
            String temp = "";
            String mons = "";
            String cons = "";
            String name =  eh[0].substring(2).split("\"")[0];

            for(int x = 1; x< eh.length; x++)
            {
                Matcher matcher = Pattern.compile("\\d+").matcher(eh[x]);
                matcher.find();
                temp = "Pin " + matcher.group() + "\n";
                if(eh[x].contains("function\":\"true\"")){
                    mons+= temp;
                }else {
                    cons += temp;
                }
                ret = "Pi Name: " + name + "\n\n" + "Monitor Pins: \n" + mons + "Control Pins: \n" + cons;
                //  temp+=element.parseInt() +"\n \n";
            }
            //String k = MyTestService.PiJSON;
            setText(ret);

        }
    }

}
