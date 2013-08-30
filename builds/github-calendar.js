(function() {
  'use strict';
  var GITHUB_USER_URL, daysBetween, draw, eventMap, eventsHandler, isSameDay, model, page, paintGrids, paintText, processedUrls;

  GITHUB_USER_URL = 'https://api.github.com/users';

  page = 1;

  model = [];

  eventMap = {};

  processedUrls = 0;

  this.Date.prototype.format = function() {
    return this.getUTCFullYear() + '-' + (this.getUTCMonth() + 1) + '-' + this.getUTCDate();
  };

  this.Date.prototype.getWeek = function() {
    var date, firstDayOfThisYear;
    date = new Date(this.getTime());
    firstDayOfThisYear = new Date(date.getUTCFullYear(), 0, 1);
    date.setDate(date.getUTCDate() + firstDayOfThisYear.getUTCDay());
    return Math.ceil((date - firstDayOfThisYear) / 1000 / 60 / 60 / 24 / 7);
  };

  daysBetween = function(date1, date2) {
    var d1, d2, ms;
    d1 = new Date(date1.getTime());
    d1.setUTCHours(0);
    d1.setUTCMinutes(0);
    d1.setUTCSeconds(0);
    d2 = new Date(date2.getTime());
    d2.setUTCHours(0);
    d2.setUTCMinutes(0);
    d2.setUTCSeconds(0);
    ms = Math.abs(d1 - d2);
    return floor(ms / 1000 / 60 / 60 / 24);
  };

  isSameDay = function(date1, date2) {
    return date1.getUTCFullYear() === date2.getUTCFullYear() && date1.getUTCMonth() === date2.getUTCMonth() && date1.getUTCDate() === date2.getUTCDate();
  };

  paintText = function(paper) {
    var currentMonth, i, m, month, x, _i;
    month = {
      0: 'Jan',
      1: 'Feb',
      2: 'Mar',
      3: 'Apr',
      4: 'May',
      5: 'Jun',
      6: 'Jul',
      7: 'Aug',
      8: 'Sep',
      9: 'Oct',
      10: 'Nov',
      11: 'Dec'
    };
    currentMonth = (new Date).getUTCMonth();
    for (i = _i = 0; _i <= 12; i = ++_i) {
      m = (currentMonth + i) % 12;
      x = i * 45;
      paper.text(x + 26, 5, month[m]);
    }
    paper.text(4, 31, 'M');
    paper.text(4, 53, 'W');
    return paper.text(4, 76, 'F');
  };

  paintGrids = function(paper, row, col, model) {
    var darkgreen, grassgreen, green, lightgreen, square,
      _this = this;
    green = '#8cc665';
    lightgreen = '#d6e685';
    grassgreen = '#44a340';
    darkgreen = '#1e6823';
    square = paper.rect(col * 11 + 15, row * 11 + 15, 10, 10);
    if (model.commitsLength > 0 && model.commitsLength < 3) {
      square.attr("fill", lightgreen);
    } else if (model.commitsLength >= 3 && model.commitsLength < 6) {
      square.attr("fill", green);
    } else if (model.commitsLength >= 6 && model.commitsLength < 8) {
      square.attr("fill", grassgreen);
    } else if (model.commitsLength >= 8) {
      square.attr("fill", darkgreen);
    } else {
      square.attr("fill", "#ccc");
    }
    square.attr("stroke-opacity", "0");
    return square.hover((function() {
      $(_this).find('.brief').html('<div style="text-align:left;float:left">' + model.created_at.format() + '</div>');
      $(_this).find('.brief').append('<div style="text-align:right;">' + model.commitsLength + ' commits</div>');
      $(_this).find('.brief').css('opacity', 1);
      $(_this).find('.description').css('opacity', 1);
      $(_this).find('.description').html('');
      !!model.commits && model.commits.forEach(function(c) {
        return $(_this).find('.description').append('<li style="text-overflow:ellipsis;overflow:hidden;padding:5px 10px;">' + model.repo.name + ' - ' + c.message + '</li>');
      });
      return square.attr("stroke-opacity", "1");
    }), (function() {
      $(_this).find('.brief').css('opacity', 0);
      $(_this).find('.description').css('opacity', 0);
      return square.attr("stroke-opacity", "0");
    }));
  };

  draw = function(paper) {
    var commitsLength, e, grid, i, _i, _len, _results;
    paintText.call(this, paper);
    _results = [];
    for (i = _i = 0, _len = model.length; _i < _len; i = ++_i) {
      grid = model[i];
      if (eventMap.hasOwnProperty(grid.created_at.format())) {
        e = eventMap[grid.created_at.format()];
        commitsLength = e.payload.commits ? e.payload.commits.length : 0;
        grid.commitsLength = commitsLength;
        if (e.payload.commits) {
          grid.commits = e.payload.commits;
        }
        if (e.repo) {
          grid.repo = e.repo;
        }
        grid.created_at = new Date(e.created_at);
      }
      _results.push(paintGrids.call(this, paper, i % 7, Math.floor(i / 7), grid));
    }
    return _results;
  };

  eventsHandler = function(events, el) {
    var paper;
    paper = Raphael($(el).offset().left, $(el).offset().top + 40, 600, 100);
    events.forEach(function(e) {
      var commitsLength, created_at, key, _base, _base1;
      (_base = e.payload).commits || (_base.commits = []);
      commitsLength = e.payload.commits ? e.payload.commits.length : 0;
      created_at = new Date(e.created_at);
      key = created_at.format('yyyy-mm-dd');
      if (!!eventMap[key]) {
        e.payload.commits.forEach(function(c) {
          if (!!eventMap[key].payload.commits) {
            return eventMap[key].payload.commits.push(c);
          }
        });
      } else {
        eventMap[key] = e;
      }
      return (_base1 = eventMap[key].payload).commits || (_base1.commits = []);
    });
    processedUrls += 1;
    if (processedUrls === 10) {
      console.log('draw....');
      return draw.call(el, paper);
    }
  };

  $.fn.calendar = function(options) {
    var urls, user;
    user = options.user || 'eguitarz';
    urls = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(function(i) {
      return GITHUB_USER_URL + '/' + user + '/events?page=' + i;
    });
    return this.each(function() {
      var date, el, end, i, today, _i;
      el = this;
      $(this).append($('<div class="brief" style="-webkit-transition:opacity 300ms;-moz-transition:opacity 300ms;background-color:#ddd;z-index:999;width:580px;padding:5px 10px;border-radius:5px;opacity:0">'));
      $(this).append($('<ul class="description" style="-webkit-transition:opacity 300ms;-moz-transition:opacity 300ms;background-color:#ddd;z-index:999;width:600px;overflow:hidden;border-radius:5px;white-space:nowrap;padding:0;list-style-type:none;margin-top:115px">'));
      today = new Date();
      end = 364 + today.getUTCDay();
      for (i = _i = 0; 0 <= end ? _i <= end : _i >= end; i = 0 <= end ? ++_i : --_i) {
        date = new Date(today.getTime());
        date.setDate(today.getUTCDate() - i);
        model.unshift({
          created_at: date,
          commitsLength: 0
        });
      }
      return urls.forEach(function(url) {
        return $.get(url).done(function(data) {
          return eventsHandler(data, el);
        });
      });
    });
  };

}).call(this);
