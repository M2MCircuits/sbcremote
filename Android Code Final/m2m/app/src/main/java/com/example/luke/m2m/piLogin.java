package com.example.luke.m2m;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import m2m.app.api.weavedapi;

public class piLogin extends ActionBarActivity {
    int index = 0;
    Set<String> pinames;
    Set<String> pipasses;
    public static final String MyPREFERENCES = "MyPrefs" ;
    public static final String Login = "loginKey";
    public static final String Pass = "passKey";
    SharedPreference2 sharedpreference2;
    Activity context = this;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pi_login);
        pinames =  new HashSet<String>();
        pipasses =  new HashSet<String>();


    }

    public void loginFClick(View view) {
        EditText lEdit   = (EditText)findViewById(R.id.input_email);
        String piName = index + lEdit.getText().toString();
        EditText pEdit   = (EditText)findViewById(R.id.input_password);
        String piPass = index + pEdit.getText().toString();
        pinames.add(piName);
        pipasses.add(piPass);
        //not workign for no reason
      //  sharedpreference2.saveSet(getApplicationContext(), pinames, 0);
       // sharedpreference2.saveSet(getApplicationContext(), pipasses, 1);



        //writeToFile(piName, index + "piName");
        //writeToFile(piPass, index + "piPass");
        weavedapi WeavedAPI = new weavedapi();
        WeavedAPI.login(readFromFile("logininfo"), readFromFile("logincredentials"));
        if(true){
            Context context = getApplicationContext();
            CharSequence text = "Pi Successfully Added";
            int duration = Toast.LENGTH_SHORT;
            Toast toast = Toast.makeText(context, text, duration);
            toast.show();
            //if successful take them out of login page
            Intent intent = new Intent(this, MainActivity.class);
            startActivity(intent);
        }else{
            Context context = getApplicationContext();
            CharSequence text = "Login Failed. Pi Not Added. Please Try again";
            int duration = Toast.LENGTH_SHORT;

            Toast toast = Toast.makeText(context, text, duration);
            toast.show();

        }

    }

    public void loginAClick(View view) {
        EditText lEdit   = (EditText)findViewById(R.id.input_email);
        String piName = index + lEdit.getText().toString();
        EditText pEdit   = (EditText)findViewById(R.id.input_password);
        String piPass = index + pEdit.getText().toString();
        pinames.add(piName);
        pipasses.add(piPass);
      //  writeToFile(piName, index + "piName");
       // writeToFile(piPass, index + "piPass");

        weavedapi WeavedAPI = new weavedapi();
        WeavedAPI.login(readFromFile("logininfo"), readFromFile("logincredentials"));
        if(true){
            index++;
            Context context = getApplicationContext();
            CharSequence text = "Pi Successfully Added";
            int duration = Toast.LENGTH_SHORT;
            Toast toast = Toast.makeText(context, text, duration);
            toast.show();
        }else{
            Context context = getApplicationContext();
            CharSequence text = "Login Failed. Pi Not Added. Please Try again";
            int duration = Toast.LENGTH_SHORT;

            Toast toast = Toast.makeText(context, text, duration);
            toast.show();

        }

    }

    private void writeToFile(String data, String name) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(getApplicationContext().openFileOutput(name +".txt", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }
    private String readFromFile(String name) {

        String ret = "";

        try {
            InputStream inputStream = openFileInput(name + ".txt");

            if ( inputStream != null ) {
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String receiveString = "";
                StringBuilder stringBuilder = new StringBuilder();

                while ( (receiveString = bufferedReader.readLine()) != null ) {
                    stringBuilder.append(receiveString);
                }

                inputStream.close();
                ret = stringBuilder.toString();
            }
        }
        catch (FileNotFoundException e) {
            Log.e("login activity", "File not found: " + e.toString());
        } catch (IOException e) {
            Log.e("login activity", "Can not read file: " + e.toString());
        }

        return ret;
    }





}
