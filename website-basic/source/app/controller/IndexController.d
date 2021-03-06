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

import hunt.logging;
import hunt.framework.application;
import hunt.framework.http;
import hunt.framework.view;
import hunt.validation;
import hunt.framework.application.MiddlewareInterface;
import hunt.framework.application.BreadcrumbsManager;

import core.time;

import std.conv;
import std.array;
import std.stdio;
import std.datetime;
import std.json;
import std.string;

import hunt.framework;
import hunt.logging;

version (USE_ENTITY) import app.model.index;
import app.model.ValidForm;

class Task1 : Task {
	this(int a, int b) {
		_a = a;
		_b = b;
	}

	override void exec() {
		logDebug("taskid : ", this.tid, ", do job ", _a, " + ", _b, " = ", _a + _b);
	}

private:
	int _a;
	int _b;
}

class IpFilterMiddleware : MiddlewareInterface {
	override string name() {
		return IpFilterMiddleware.stringof;
	}

	override Response onProcess(Request req, Response res) {
		// writeln(req.session());
		return null;
	}
}

/**
*/
class IndexController : Controller {
	mixin MakeController;

	this() {
		this.addMiddleware(new IpFilterMiddleware());
	}

	override bool before() {
		logDebug("---running before----");

		if (toUpper(request.methodAsString) == HttpMethod.OPTIONS.asString())
			return false;
		return true;
	}

	override bool after() {
		logDebug("---running after----");
		return true;
	}

	@Action string index() {
		JSONValue model;
		model["title"] = "Hunt demo";
		import hunt.util.DateTime;

		model["stamp"] = time();
		model["now"] = Clock.currTime.toString();
		view.setTemplateExt(".dhtml");
		view.assign("model", model);
		view.assign("app",parseJSON(`{"name":"Hunt"}`));
		view.assign("breadcrumbs", breadcrumbsManager.generate("home"));
		return view.render("home");
	}

	Response showAction() {
		logDebug("---show Action----");
		// dfmt off
		Response response = new Response(this.request);
		response.setContent("Show message(No @Action defined): Hello world<br/>");
		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8")
		.header("X-Header-One", "Header Value")
		.withHeaders(["X-Header-Two":"Header Value", "X-Header-Tree": "Header Value"]);
		// dfmt on
		return response;
	}

	Response test_action() {
		logDebug("---test_action----");
		// dfmt off
		response.setContent("Show message: Hello world<br/>")
		.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
		// dfmt on

		return response;
	}

	// @Action void showVoid()
	// {
	// 	logDebug("---show void----");
	// }

	@Action string showString() {
		logDebug("---show string----");
		return "Hello world.";
	}

	@Action bool showBool() {
		logDebug("---show bool----");
		return true;
	}

	@Action int showInt() {
		logDebug("---test Routing1----", this.request.get("id"));
		return 2018;
	}

	@Action string testRouting2(int id) {
		logDebug("---test Routing2----", this.request.queries);
		return "The router parameter(id) is: " ~ id.to!string;
	}

	@Action Response setCookie() {
		logDebug("---test Cookie ----");
		Cookie cookie1 = new Cookie("name1", "value1", 1000);
		Cookie cookie2 = new Cookie("name2", "value2", 1200, "/path");
		Cookie cookie3 = new Cookie("name3", "value3", 4000);
		// dfmt off
		Response response = new Response(this.request);
		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8")
		.withCookie(cookie1)
		.withCookie(cookie2)
		.withCookie(cookie3)
		.header("X-Header-One", "Header Value")
		.withHeaders(["X-Header-Two":"Header Value", "X-Header-Tree": "Header Value"]);
		// dfmt on

		response.setContent("Three cookies are set.<br/>");
		response.writeContent(cookie1.toString() ~ "<br/>");
		response.writeContent(cookie2.toString() ~ "<br/>");
		response.writeContent(cookie3.toString() ~ "<br/>");

		return response;
	}

	@Action Response getCookie() {

		auto response = new Response(this.request);
		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());

		Cookie[] cookies = this.request.getCookies();
		if (cookies.length > 0) {
			response.writeContent("Found cookies:<br/>");
			foreach (Cookie c; cookies) {
				response.writeContent(format("%s=%s<br/>", c.getName(), c.getValue()));
			}
		} else
			response.setContent("No cookie found.");
		return response;
	}

	@Action JSONValue testJson1() {
		logDebug("---test Json1----");
		JSONValue js;
		js["message"] = "Hello world.";
		return js;
	}

	@Action JsonResponse testJson2() {
		logDebug("---test Json2----");
		JSONValue company;
		company["name"] = "Putao";
		company["city"] = "Shanghai";

		JsonResponse res = new JsonResponse(this.request, company);
		return res;
	}

	@Action string showView() {
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
		
		return view.render("default/index");
	}

	@Action FileResponse testDownload() {
		string file = request.get("file", "putao.png");
		file = "attachments/" ~ file;
		FileResponse r = new FileResponse(file);
		return r;
	}

	@Action RedirectResponse testRedirect1() {
		HttpSession session = request.session(true);
		session.set("test", "for RedirectResponse");
		RedirectResponse r = new RedirectResponse(this.request, "https://www.putao.com/");
		return r;
	}

	@Action RedirectResponse testRedirect2() {
		RedirectResponse r = new RedirectResponse(this.request, "https://www.putao.com/");
		return r;
	}

	@Action Response setCache() {
		HttpSession session = request.session(true);
		session.set("test", "current value");

		string key = request.get("key");
		string value = request.get("value");
		cache.put(key, value);

		Appender!string stringBuilder;

		stringBuilder.put("Cache test: <br/>");
		stringBuilder.put("key : " ~ key ~ " value : " ~ value);
		stringBuilder.put("<br/><br/>Session Test: ");
		stringBuilder.put("<br/>SessionId: " ~ session.getId());
		stringBuilder.put("<br/>key: test, value: " ~ session.get("test"));

		// request.flush(); // Can be called automatically by Response.done.

		Response response = new Response(this.request);
		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);
		return response;
	}

	@Action Response getCache() {
		HttpSession session = request.session();

		string key = request.get("key");
		string value = cache.get!(string)(key);

		Appender!string stringBuilder;
		stringBuilder.put("Cache test:<br/>");
		stringBuilder.put(" key: " ~ key ~ ", value: " ~ value);

		if (session !is null) {
			string sessionValue = session.get("test");
			stringBuilder.put("<br/><br/>Session Test: ");
			stringBuilder.put("<br/>  SessionId: " ~ session.getId);
			stringBuilder.put("<br/>  key: test, value: " ~ sessionValue);
		}

		Response response = new Response(this.request);
		response.setContent(stringBuilder.data).setHeader(HttpHeader.CONTENT_TYPE,
				MimeType.TEXT_HTML_UTF_8.asString());

		return response;
	}

	@Action Response createTask() {
		string interval = request.get("interval");
		string value1 = request.get("value1");
		string value2 = request.get("value2");

		auto t1 = new Task1(to!int(value1), to!int(value2));
		t1.setFinish((Task t) {
			try {
				logDebug("the task is finish : ", t.tid);
			} catch (Exception e) {
			}
		});

		auto taskid = GetTaskMObject().put(t1, dur!"seconds"(to!int(interval)));

		Response response = new Response(this.request);
		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
		response.setContent("the task id : " ~ to!string(taskid));
		return response;
	}

	@Action Response stopTask() {
		string taskid = request.get("taskid");
		Response response = new Response(this.request);

		if (taskid.empty()) {
			response.setContent("The task id is empty!");
		} else {
			auto ok = GetTaskMObject.del(to!size_t(taskid));
			response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
			response.setContent("stop task (" ~ taskid ~ ") : " ~ to!string(ok));

		}
		return response;
	}

	@Action Response testForm1() {
		Response response = new Response(this.request);
		import std.conv;

		Appender!string stringBuilder;
		stringBuilder.put("<p>Form data from xFormData:<p/>");
		foreach (string key, string[] values; this.request.xFormData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
		}

		stringBuilder.put("<p>Form data from post:<p/>");
		foreach (string key, string[] values; this.request.xFormData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ this.request.post(key) ~ "<br/>");
		}

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	@Action Response testUpload() {
		Response response = new Response(this.request);
		import std.conv;
		import hunt.framework.file.UploadedFile;

		Appender!string stringBuilder;

		stringBuilder.put("<br/>Uploaded files:<br/>");
		import hunt.http.codec.http.model.MultipartFormInputStream;
		import std.format;
		import hunt.text.StringUtils;

		foreach (UploadedFile p; request.allFiles()) {
			// string content = cast(string) mp.getBytes();
			p.move("Multipart file - " ~ StringUtils.randomId());
			stringBuilder.put(format("File: fileName=%s, actualFile=%s<br/>",
					p.originalName(), p.path()));
			// stringBuilder.put("<br/>content:" ~ content);
			stringBuilder.put("<br/><br/>");
		}

		foreach (string key, string[] values; request.xFormData) {
			stringBuilder.put(format("Form data: key=%s, value=%s<br/>",
					 key, values));
			stringBuilder.put("<br/><br/>");
		}

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	@Action Response testValidForm(User user) {

		auto result = user.valid();
		logDebug(format("user( %s , %s , %s ) ,isValid : %s , valid result : %s ",
				user.name, user.age, user.email, result.isValid, result.messages()));
		Response response = new Response(this.request);

		Appender!string stringBuilder;
		stringBuilder.put("<p>Form data:<p/>");
		foreach (string key, string[] values; this.request.xFormData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
		}

		stringBuilder.put("<br/>");
		stringBuilder.put("validation result:<br/>");
		stringBuilder.put(format("isValid : %s , valid result : %s<br/>",
				result.isValid, result.messages()));

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	@Action Response testMultitrans() {
		logDebug("url : ", request.url);
		Cookie cookie;
		Response response = new Response(this.request);
		if (request.url == "/zh") {
			cookie = new Cookie("Content-Language", "zh-cn");
			view.setLocale("zh-cn");
		} else {
			cookie = new Cookie("Content-Language", "en-us");
			view.setLocale("en-us");
		}

		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8").withCookie(cookie);

		JSONValue model;
		import hunt.util.DateTime;

		model["stamp"] = time();
		model["now"] = Clock.currTime.toString();
		view.setTemplateExt(".dhtml");
		view.assign("model", model);
		view.assign("app",parseJSON(`{"name":"hunt"}`));
		view.assign("breadcrumbs", breadcrumbsManager.generate("home"));
		return response.setContent(view.render("home"));

	}
}
