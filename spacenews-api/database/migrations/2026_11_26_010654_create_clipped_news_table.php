<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('clipped_news', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->onDelete('cascade');
        $table->foreignId('mission_id')->constrained('missions')->onDelete('cascade');
        $table->string('title');
        $table->string('news_site')->nullable(); // Sumber berita
        $table->text('image_url')->nullable();
        $table->text('notes')->nullable(); // Ringkasan / Catatan
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('clipped_news');
    }
};
