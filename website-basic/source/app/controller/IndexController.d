/*
 * Hunt - Hunt is a high-level D Programming Language Web framework that encourages rapid development and clean, pragmatic design. It lets you build high-performance Web applications quickly and easily.
 *
 * Copyright (C) 2015-2016  Shanghai Putao Technology Co., Ltd 
 *
 * Developer: putao's Dlang team
 *
 * Licensed under the BSD License.
 *
 */
module app.controller.IndexController;

import kiss.logger;
import hunt.application;
import hunt.http;
import hunt.view;

import core.time;

import std.array;
import std.stdio;
import std.datetime;
import std.json;
import hunt.task;
import hunt;

version (USE_ENTITY) import app.model.index;


class Task1 : Task
{
	this(int a,int b)
	{
		_a = a;
		_b = b;
	}
	override void exec()
	{
		logDebug("taskid : ",this.tid,", do job ",_a," + ",_b ," = ",_a+_b);
	}

	private : 
		int _a;
		int _b;
}

class IpFilterMiddleware : MiddlewareInterface
{
	override string name()
	{
		return IpFilterMiddleware.stringof;
	}

	override Response onProcess(Request req, Response res)
	{
		writeln(req.session());
		return null;
	}
}

/**
*/
class IndexController : Controller
{
	mixin MakeController;
	this()
	{
		this.addMiddleware(new IpFilterMiddleware());
	}

	override bool before()
	{
		logDebug("---running before----");

		if (cmp(toUpper(request.method), HttpMethod.Options) == 0)
			return false;
		return true;
	}

	override bool after()
	{
		logDebug("---running after----");
		return true;
	}

	@Action string index()
	{
		JSONValue model;
		model["title"] = "Hunt demo";
		model["now"] = Clock.currTime.toString();
		view.setTemplateExt(".dhtml");
		view.assign("model", model);
		return view.render("home");
	}

	Response showAction()
	{
		logDebug("---show Action----");
		// dfmt off
		Response response = new Response("Show message(No @Action defined): Hello world<br/>"); 
		response.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8")
		.setCookie("name", "value", 10000)
		.setCookie("name1", "value", 10000, "/path")
		.cookie("name2", "value", 10000)
		.header("X-Header-One", "Header Value")
		.withHeaders(["X-Header-Two":"Header Value", "X-Header-Tree": "Header Value"]);
		// dfmt on
		return response;
	}

	Response test_action()
	{
		logDebug("---test_action----");
		// dfmt off
		response.setContent("Show message: Hello world<br/>")
		.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8")
		.setCookie("name", "value", 10000)
		.setCookie("name1", "value", 10000, "/path")
		.setCookie("name2", "value", 10000);
		// dfmt on

		return response;
	}

	@Action void showVoid()
	{
		logDebug("---show void----");
	}

	@Action string showString()
	{
		logDebug("---show string----");
		return "Hello world.";
	}

	@Action bool showBool()
	{
		logDebug("---show bool----");
		return true;
	}

	@Action int showInt()
	{
		logDebug("---show int----", this.request.get("id"));
		return 2018;
	}

	@Action string showInt2()
	{
		logDebug("---show int----", this.request.get("id"));
		return this.request.get("id");
	}


	@Action JSONValue testJson1()
	{
		logDebug("---test Json1----");
		JSONValue js;
		js["message"] = "Hello world.";
		return js;
	}

	@Action JsonResponse testJson2()
	{
		logDebug("---test Json2----");
		JSONValue company;
		company["name"] = "Putao";
		company["city"] = "Shanghai";

		JsonResponse res = new JsonResponse(company);
		return res;
	}

	@Action string showView()
	{
		JSONValue data;
		data["name"] = "Cree";
		data["alias"] = "Cree";
		data["city"] = "Christchurch";
		data["age"] = 3;
		data["age1"] = 28;
		data["addrs"] = ["ShangHai", "BeiJing"];
		data["is_happy"] = false;
		data["allow"] = false;
		data["users"] = ["name" : "jeck", "age" : "18"];
		data["nums"] = [3, 5, 2, 1];

		view.setTemplateExt(".txt");
		view.assign("model", data);

		return view.render("index");
	}

	@Action DownloadResponse testDownload()
	{
		string file = request.get("file", "putao.png");
		DownloadResponse r = new DownloadResponse(file).loadData();
		return r;
	}

	@Action RedirectResponse testRedirect1()
	{
		RedirectResponse r = new RedirectResponse("https://www.putao.com/");
		return r;
	}

	@Action RedirectResponse testRedirect2()
	{
		// TODO: Tasks pending completion -@zxp at 5/24/2018, 3:09:41 PM
		// 
		RedirectResponse r = new RedirectResponse("https://www.putao.com/");
		return r;
	}

	@Action Response setCache()
	{
		Session session = request.session();
		session.set("test", "current value");

		string key = request.get("key");
		string value = request.get("value");
		cache.put(key, value);

		Appender!string stringBuilder;

		stringBuilder.put("Cache test: <br/>");
		stringBuilder.put("key : " ~ key ~ " value : " ~ value);
		stringBuilder.put("<br/><br/>Session Test: ");
		stringBuilder.put("<br/>SessionId: " ~ session.sessionId);
		stringBuilder.put("<br/>key: test, value: " ~ session.get("test"));

		Response response = this.request.createResponse();
		response.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8");
		response.setContent(stringBuilder.data);
		return response;
	}

	@Action Response getCache()
	{
		Session session = request.session();
		string sessionValue = session.get("test");

		string key = request.get("key");
		string value = cache.get!(string)(key);

		Appender!string stringBuilder;
		stringBuilder.put("Cache test:<br/>");
		stringBuilder.put(" key: " ~ key ~ ", value: " ~ value);

		stringBuilder.put("<br/><br/>Session Test: ");
		stringBuilder.put("<br/>  SessionId: " ~ session.sessionId);
		stringBuilder.put("<br/>  key: test, value: " ~ sessionValue);

		Response response = this.request.createResponse();
		response.setContent(stringBuilder.data)
			.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8");

		return response;
	}

	@Action Response createTask()
	{
		string interval = request.get("interval");
		string value1 = request.get("value1");
		string value2 = request.get("value2");

		auto t1 = new Task1(to!int(value1),to!int(value2));
		t1.setFinish((Task t){
			try{
				logDebug("the task is finish : ",t.tid);
			}catch(Exception e){}
		});
		
		auto taskid = Application.getInstance().task().put(t1,dur!"seconds"(to!int(interval)));

		Response response = this.request.createResponse();
		response.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8");
		response.setContent("the task id : " ~ to!string(taskid));
		return response;
	}

	@Action Response stopTask()
	{
		string taskid = request.get("taskid");

		auto ok = Application.getInstance().task.del(to!size_t(taskid));

		Response response = this.request.createResponse();
		response.setHeader(HttpHeaderCode.CONTENT_TYPE, "text/html;charset=utf-8");
		response.setContent("stop task (" ~ taskid ~ ") : " ~ to!string(ok));
		return response;
	}
}
