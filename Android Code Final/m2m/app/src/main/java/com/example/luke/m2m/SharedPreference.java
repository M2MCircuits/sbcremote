package com.example.luke.m2m;
        import android.app.Activity;
        import android.content.Context;
        import android.content.SharedPreferences;
        import android.content.SharedPreferences.Editor;
        import android.preference.PreferenceManager;

        import java.util.ArrayList;
        import java.util.Set;

public class SharedPreference {

    public static final String PREFS_NAME = "AOP_PREFS";
    public static final String PREFS_KEY = "AOP_PREFS_String";
    public static final String loginKey = "login_String";
    public static final String passKey = "pass_String";
    public static final String piNameKey= "pi_name_String";
    public static final String piPassKey= "pi_pass_String";

    public SharedPreference() {
        super();
    }

    public void save(Context context, String text, int x) {
        SharedPreferences settings;
        Editor editor;

        //settings = PreferenceManager.getDefaultSharedPreferences(context);
        switch (x) {
            case 0:
               // settings = context.getSharedPreferences(loginKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putString(loginKey, text); //3
                editor.commit(); //4
                break;
            case 1:
               // settings = context.getSharedPreferences(passKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putString(passKey, text); //3
                editor.commit(); //4
                break;
            default: //settings = context.getSharedPreferences(passKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putString(PREFS_KEY, text); //3
                editor.commit(); //4
        }


    }

    public String getValue(Context context, int x) {
        SharedPreferences settings;
        String text;
        //settings = PreferenceManager.getDefaultSharedPreferences(context);
        settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        switch (x) {
            case 0:
                text = settings.getString(loginKey, null);
                break;
            case 1:
                text = settings.getString(passKey, null);
                break;
            default: text = settings.getString(PREFS_KEY, null);
        }

        return text;
    }

    public void clearSharedPreference(Context context) {
        SharedPreferences settings;
        Editor editor;

        //settings = PreferenceManager.getDefaultSharedPreferences(context);
        settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        editor = settings.edit();

        editor.clear();
        editor.commit();
    }

    public void removeValue(Context context) {
        SharedPreferences settings;
        Editor editor;

        settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        editor = settings.edit();

        editor.remove(PREFS_KEY);
        editor.commit();
    }

    public void saveSet(Context context, Set<String> text, int x){
        SharedPreferences settings;
        Editor editor;

        //settings = PreferenceManager.getDefaultSharedPreferences(context);
        switch (x) {
            case 0:
                System.out.println("saving");
                // settings = context.getSharedPreferences(loginKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putStringSet(piNameKey, text); //3
                editor.commit(); //4
                break;
            case 1:
                // settings = context.getSharedPreferences(passKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putStringSet(piPassKey, text); //3
                editor.commit(); //4
                break;
            default: //settings = context.getSharedPreferences(passKey, Context.MODE_PRIVATE);
                settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE); //1
                editor = settings.edit(); //2
                editor.putStringSet(PREFS_KEY, text); //3
                editor.commit(); //4
        }


    }
    public Set<String> getValueSet(Context context, int x) {
        SharedPreferences settings;
        Set<String> set;
        //settings = PreferenceManager.getDefaultSharedPreferences(context);
        settings = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        switch (x) {
            case 0:
                set = settings.getStringSet(piNameKey, null);
                break;
            case 1:
                set = settings.getStringSet(piPassKey, null);
                break;
            default: set = settings.getStringSet(PREFS_KEY, null);
        }

        return set;
    }

}