package com.example.luke.m2m;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

import m2m.app.api.weavedapi;

public class setPins extends ActionBarActivity {
    int pin = -1;
    int index = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_set_pins);
    }

    public void pressTrue(View view) {

        EditText mEdit   = (EditText)findViewById(R.id.editText);
        String temp =mEdit.getText().toString();
        EditText mEdit2   = (EditText)findViewById(R.id.editText2);
        String temp2 =mEdit.getText().toString();

        if(!temp.equals("") && !temp2.equals("") )
        {
            pin = Integer.parseInt(mEdit.getText().toString());
            index = Integer.parseInt(mEdit2.getText().toString());
            setToast("Setting Pin, Please Wait");
            new setPinTask().execute(true);}
        else{
            setToast("Please Select a Pin to Set");
        }

    }

    public void pressFalse(View view) {
        EditText mEdit   = (EditText)findViewById(R.id.editText);
        String temp =mEdit.getText().toString();
        EditText mEdit2   = (EditText)findViewById(R.id.editText2);
        String temp2 =mEdit.getText().toString();

        if(!temp.equals("") && !temp2.equals("") )
        {
            pin = Integer.parseInt(mEdit.getText().toString());
            index = Integer.parseInt(mEdit2.getText().toString());
            setToast("Setting Pin, Please Wait");
            new setPinTask().execute(false);}
        else{
            setToast("Please Select a Pin to Set");
        }
    }

    protected void setToast(String s){
        Toast toast = Toast.makeText(getApplicationContext(), s, Toast.LENGTH_LONG);
        toast.show();
    }


    //Asyncronous Task to set pins info
    private class setPinTask extends AsyncTask<Boolean, Void, Boolean> {
        @Override
        protected Boolean doInBackground(Boolean... bool) {
            Boolean temp = bool[0];
                try {
                    weavedapi WeavedAPI = new weavedapi();
                    //WeavedAPI.login(login, pass);
                    WeavedAPI.login("siddhesh.singh@utdallas.edu", "newpass2");
                    WeavedAPI.setup(false);
                    WeavedAPI.setPiCreds(index, "webiopi", "raspberry");
                    WeavedAPI.genPiProxy(index);
                    WeavedAPI.setupPi(index, false, "");
                    WeavedAPI.updatePi(index);
                    WeavedAPI.SetPiGPIOPinFunction(index, pin, false, false);
                    WeavedAPI.SetPiGPIOPinValue(index, pin, temp, false);
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                    setToast("Pin Set Failed");

                }
            return temp;
        }

        @Override
        //Author:Luke New
        //Sets text after downloading.
        protected void onPostExecute(Boolean result) {
            if(result) {
                setToast("pin state changed to true");
            }else{
                setToast("pin state changed to false");
            }


        }
    }
}
