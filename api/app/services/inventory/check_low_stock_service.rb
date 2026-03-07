module Inventory
  class CheckLowStockService < ApplicationService
    attr_accessor :organization, :course, :category

    validates :organization, presence: true

    def call
      return failure(errors.full_messages) unless valid?

      query = build_query
      low_stock_items = query.includes(:pos_product, :course).low_stock.order(:current_stock)
      
      # Group by course for better organization
      grouped_items = low_stock_items.group_by(&:course)
      
      # Calculate totals
      total_items = low_stock_items.count
      total_value_at_risk = calculate_total_value_at_risk(low_stock_items)
      
      success(
        low_stock_items: low_stock_items,
        grouped_by_course: grouped_items,
        total_items_low: total_items,
        total_value_at_risk_cents: total_value_at_risk,
        summary: generate_summary(grouped_items)
      )
    rescue StandardError => e
      failure([e.message])
    end

    private

    def build_query
      query = InventoryLevel.for_organization(organization)
      
      # Filter by course if specified
      query = query.for_course(course) if course
      
      # Filter by category if specified
      if category
        query = query.joins(:pos_product).where(pos_products: { category: category })
      end
      
      query
    end

    def calculate_total_value_at_risk(low_stock_items)
      low_stock_items.sum do |item|
        needed_quantity = [item.reorder_point - item.current_stock, 0].max
        item.average_cost_cents.to_f * needed_quantity
      end
    end

    def generate_summary(grouped_items)
      summary = {}
      
      grouped_items.each do |course, items|
        course_summary = {
          course_name: course.name,
          items_count: items.count,
          categories: items.group_by { |item| item.pos_product.category }.transform_values(&:count),
          most_critical: find_most_critical_item(items)
        }
        
        summary[course.id] = course_summary
      end
      
      summary
    end

    def find_most_critical_item(items)
      # Find the item with the lowest stock relative to its reorder point
      most_critical = items.min_by do |item|
        next Float::INFINITY if item.reorder_point == 0
        item.current_stock.to_f / item.reorder_point
      end
      
      return nil unless most_critical
      
      {
        product_name: most_critical.pos_product.name,
        current_stock: most_critical.current_stock,
        reorder_point: most_critical.reorder_point,
        stock_percentage: most_critical.reorder_point > 0 ? 
          (most_critical.current_stock.to_f / most_critical.reorder_point * 100).round(1) : 0
      }
    end
  end
end